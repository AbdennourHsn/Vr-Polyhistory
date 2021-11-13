Shader "Quantum Theory/OLD PBR - Puddle Decal" {
		Properties{
			_BumpMap("Normal Map", 2D) = "bump" {}
		_MainTex("Base Color", 2D) = "white" {}
		_MetallicGlossMap("Material", 2D) = "white" {}
		_PuddleColor("Puddle Color", Color) = (0.5,0.5,0.5,1)
		//_SmoothnessModulation("Stain Smoothness Limit", Range(0, 1)) = 0.5
		_Power("Stain Power", Range(1, 3)) = 2
		_Cutoff("Alpha cutoff", Range(0,1)) = 0.5
		}
			SubShader{
			
			Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+1" "ForceNoShadowCasting" = "True" }
			Offset -2,-2
			LOD 200
			
			CGPROGRAM

		#pragma surface surf Standard alphatest:_Cutoff
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _MetallicGlossMap;
		float4 _PuddleColor;
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
			fixed4 m = tex2D(_MetallicGlossMap, IN.uv_MetallicGlossMap);			
			float n = saturate((clamp(pow((1 - IN.color.b), 8.0), 0, 0.7) + pow((1.0 - m.b), 8))); //node_4771
			float d = (n*(1.0 - IN.color.b));
			o.Albedo = lerp(pow(c.rgb, ((IN.color.r*(1.0 - _Power)) + _Power)), _PuddleColor.rgb, d); //pow(c.rgb, ((IN.color.r*(1.0 - _Power)) + _Power));
			o.Metallic = m.r;
			o.Smoothness = lerp(n, m.a, IN.color.b);
			float3 texNormal =  UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			float inverse = 1.0 - n;
			o.Normal = float3(texNormal.r*inverse, texNormal.g*inverse, texNormal.b);
			
			o.Occlusion = saturate((m.g + pow(d,5)));
			o.Alpha = IN.color.g*(m.b + 0.5);
		}
		ENDCG
		}
			FallBack "Diffuse"
	}
