Shader "Quantum Theory/PBR - Wetness Blend" {
		Properties{
		_BumpMap("Normal Map", 2D) = "bump" {}
		_MainTex("Base Color", 2D) = "white" {}
		_MetallicGlossMap("Material", 2D) = "white" {}
		_BumpMapB("Normal Map 2", 2D) = "bump" {}
		_MetallicGlossMapB("Material 2", 2D) = "white" {}
		_MainTexB("Base Color 2", 2D) = "white" {}
		_SmoothnessModulation("Stain Smoothness Limit", Range(0, 1)) = 0.5
		_Power("Stain Power", Range(1, 3)) = 2
		}
			SubShader{
			Tags{ "RenderType" = "Opaque" }
			LOD 200
			CGPROGRAM

#pragma surface surf Standard fullforwardshadows
#pragma target 3.0

		sampler2D _MainTex, _MainTexB;
		//float4 _Maintex_ST, _MainTexB_ST;
		sampler2D _BumpMap, _BumpMapB;
		//float4 _BumpMap_ST, _BumpMapB_ST;
		sampler2D _MetallicGlossMap, _MetallicGlossMapB;
		//float4 _MetallicGlossMap_ST, _MetallicGlossMapB_ST;
		float _Power;
		float _SmoothnessModulation;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_MetallicGlossMap;
			float4 color:Color;
		};

		void surf(Input IN, inout SurfaceOutputStandard o) {

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 c2 = tex2D(_MainTexB, IN.uv_MainTex);
			fixed4 m = tex2D(_MetallicGlossMap, IN.uv_MetallicGlossMap);
			fixed4 m2 = tex2D(_MetallicGlossMapB, IN.uv_MetallicGlossMap);
			o.Albedo = pow(lerp(c2.rgb,c.rgb, IN.color.g), ((IN.color.r*(1 - _Power)) + _Power));//pow(c.rgb, ((IN.color.r*(1.0 - _Power)) + _Power));
			float3 matBlend = lerp(m2.rgb, m.rgb, IN.color.g).rgb;
			o.Metallic = matBlend.r;
			o.Smoothness = lerp(m2.a, m.a, IN.color.g) + (_SmoothnessModulation*(1 - IN.color.a));//m.a + (_SmoothnessModulation*(1.0 - IN.color.a));
			float3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			float3 normal2 = UnpackNormal(tex2D(_BumpMapB, IN.uv_BumpMap));
			o.Normal = lerp(normal2.rgb, normal1.rgb, IN.color.g);
			o.Occlusion = matBlend.g;
		}
		ENDCG
		}
			FallBack "Diffuse"
	}
