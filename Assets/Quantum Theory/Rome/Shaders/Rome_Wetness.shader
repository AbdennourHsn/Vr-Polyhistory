Shader "Quantum Theory/OLD PBR - Wetness" {
		Properties{
			_BumpMap("Normal Map", 2D) = "bump" {}
		_MainTex("Base Color", 2D) = "white" {}
		_MetallicGlossMap("Material", 2D) = "white" {}
		_SmoothnessModulation("Stain Smoothness Limit", Range(0, 1)) = 0.5
			_Power("Stain Power", Range(1, 3)) = 2
		}
			SubShader{
			Tags{ "RenderType" = "Opaque" }
			LOD 200
			CGPROGRAM

#pragma surface surf Standard fullforwardshadows
#pragma target 3.0

			sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _MetallicGlossMap;
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
			o.Albedo = pow(c.rgb, ((IN.color.r*(1.0 - _Power)) + _Power));
			o.Metallic = m.r;
			o.Smoothness = m.a + (_SmoothnessModulation*(1.0 - IN.color.a));
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			o.Occlusion = m.g;
		}
		ENDCG
		}
			FallBack "Diffuse"
	}
