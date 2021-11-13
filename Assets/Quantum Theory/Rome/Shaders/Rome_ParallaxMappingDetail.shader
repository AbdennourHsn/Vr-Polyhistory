Shader "Quantum Theory/OLD PBR - Parallax Mapping with Detail" {
     Properties {
         _MainTex ("Albedo (RGB)", 2D) = "white" {}
         _BumpMap("NormalMap", 2D) = "white" {}
         _MetallicGlossMap ("Metallic (R) AO (G) Height (B) Smoothness (A)", 2D) = "white" {}
         _DetailNormalMap ("Detail NormalMap", 2D) = "white" {}
         _DetailAlbedoMap ("Detail Albedo", 2D) = "white" {}
         
         _HeightScale ("Height Scale", Range(-2.5,2.5)) = 0.2
    
         _TotalHeightBias ("TotalHeightBias", Range(-2,2)) = 1.0
         _TransitionCrispness ("TransitionCrispness", Range(0,128)) = 128
         _Samples ("Samples", Range(0,30)) = 15
         _DetailOffsetScale ("DetailTexturesOffsetScale", Range(-256,256)) = 4
         
         
     }
     SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard vertex:vert fullforwardshadows
		#pragma target 3.0
		//#pragma debug
		#include "UnityCG.cginc"


		struct Input {
			float2 uv_MainTex : TEXCOORD0;
			float2 uv_BumpMap : TEXCOORD1;
			float2 uv_MetallicGlossMap;
			float2 uv_DetailNormalMap;

			float3 viewVecForParallax;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			fixed4 color : COLOR;
			
		};

		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input,o);
			//o.viewDir = ObjSpaceViewDir ( v.vertex );
			TANGENT_SPACE_ROTATION;
			half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
			o.viewVecForParallax = viewDirForParallax;
			
		}

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _MetallicGlossMap;
		sampler2D _DetailNormalMap;
		sampler2D _DetailAlbedoMap;
		
		//uniform float4 _MetallicGlossMap_ST; 

		half _Glossiness;
		half _Metallic;
		float _HeightScale;
		float _TotalHeightBias;
		float _TransitionCrispness;
		float _DetailOffsetScale;
		
		
		
#ifdef USE_DEPTH_DARKENING
		float _DepthDarkeningFallof;
#endif
		int _Samples;
		fixed4 _Color;
 
 		
 		void GetLayerData(
 			float3 viewVec,
 			float2 originalUvs,
 			float2 detailAlbedoUvs,
 			float2 normalMapUvs,
 			float2 detailNormalUvs,
 			float2 mhasUvs,
 			float offsetValue,
 			float heightBias,
 			float falloff,
 			out float4 albedoResult,
 			out float3 normalResult,
 			out float4 metHeightAoSmoothness,
 			out float maskResult)
 		{
 			float2 baseOffsets = ParallaxOffset(0.0f, offsetValue, (viewVec));
 			
 			float2 uvsWithParallax = originalUvs + baseOffsets;
 			
 			float2 uvsForMHAS = mhasUvs + baseOffsets;
 			
 			float4 sampledMHAS = tex2D(_MetallicGlossMap, uvsForMHAS);//metallicAndSmoothnessFinalUVs);
 			
 			metHeightAoSmoothness = sampledMHAS;
 			maskResult = pow(saturate(sampledMHAS.b + (heightBias + _TotalHeightBias)), falloff);
 			
 			albedoResult = tex2D(_MainTex, uvsWithParallax);
 			
 			float3 detailAlbedo = tex2D(_DetailAlbedoMap, detailAlbedoUvs + baseOffsets * _DetailOffsetScale);
 			
 			albedoResult.xyz = albedoResult.xyz * detailAlbedo.xyz * 2;
 			
 			float2 uvsForNormalMap = (normalMapUvs + baseOffsets);
 			normalResult = UnpackNormal(tex2D(_BumpMap, uvsForNormalMap)).xyz;
 			
 			float3 detailNormal = UnpackNormal(tex2D(_DetailNormalMap, detailNormalUvs + baseOffsets * _DetailOffsetScale)).xyz;
			normalResult = normalize(normalResult + detailNormal);
 			
 			return;
 		}
 
		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			float2 mainUVs = IN.uv_MainTex;
			float2 normalMapUvs = IN.uv_BumpMap;
			float2 detailNormalMapUvs = IN.uv_DetailNormalMap;
			float2 mhasUvs = IN.uv_MetallicGlossMap;
			float2 detailAlbedoUvs = IN.uv_DetailNormalMap;
			
			
			
			int numSamples = _Samples;

			float4 previousAlbedo = tex2D(_MainTex, mainUVs);
			float3 previousNormal = UnpackNormal(tex2D(_BumpMap, normalMapUvs)).xyz;
			float3 detailNormal = float3(1,1,0) * UnpackNormal(tex2D(_DetailNormalMap, detailNormalMapUvs)).xyz;
			previousNormal = normalize(previousNormal + detailNormal);
			
			float4 previousMetAndSmoothness = tex2D(_MetallicGlossMap, mhasUvs);
			
			float3 detailAlbedo = tex2D(_DetailAlbedoMap, detailAlbedoUvs);
			
			previousAlbedo.xyz = previousAlbedo.xyz * detailAlbedo.xyz * 2;
			
			float firstAO = 1.0f;
			float4 albedoFinalLayered = previousAlbedo;
			
			
			
			float3 normalFinalLayered = previousNormal;
			float4 metallicAndSmoothnessFinalLayered = previousMetAndSmoothness;
			
			int totalLoops = numSamples;
			
			for(int i = totalLoops; i > 0; --i)
			{
				float linearGradient = 1.0f - i / (float)totalLoops;
				
				int layerIndex = i;
				
				float4 layerAlbedo;
				float3 layerNormal;
				float4 layerMetallicAndSmoothness;
				float layerMask;
				
				GetLayerData( 
					IN.viewVecForParallax,
					 mainUVs,
					 detailAlbedoUvs,
					 normalMapUvs,
					 detailNormalMapUvs,
					 mhasUvs,
					  -1 * (linearGradient * _HeightScale),
					  -linearGradient,
					  _TransitionCrispness,
					  layerAlbedo,
					  layerNormal,
					  layerMetallicAndSmoothness,
					  layerMask);
					  
				layerMask = saturate(layerMask);
				
				albedoFinalLayered = lerp(previousAlbedo, layerAlbedo, layerMask);
				
				normalFinalLayered = lerp(previousNormal, layerNormal, layerMask);
				
				metallicAndSmoothnessFinalLayered = lerp(previousMetAndSmoothness, layerMetallicAndSmoothness, layerMask);
				
				previousAlbedo = albedoFinalLayered;
				previousNormal = normalFinalLayered;
				previousMetAndSmoothness = metallicAndSmoothnessFinalLayered;
			}
			
			o.Albedo = albedoFinalLayered;

			o.Normal = normalFinalLayered;
			
			o.Metallic = metallicAndSmoothnessFinalLayered.x;
			o.Smoothness = metallicAndSmoothnessFinalLayered.w;
			o.Alpha = 1.0f;
			o.Occlusion = metallicAndSmoothnessFinalLayered.y;
		}
         ENDCG
     } 
     FallBack "Diffuse"
 }