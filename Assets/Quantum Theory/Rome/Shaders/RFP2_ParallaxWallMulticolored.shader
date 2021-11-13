// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Quantum Theory/PBR - Rome Wall Multicolored Parallax"
{
	Properties
	{
		_BaseColor("Base Color", 2D) = "white" {}
		_MetallicGlossMap("MetallicGlossMap", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		_GreyscaleAgeMap("Greyscale Age Map", 2D) = "white" {}
		_ColorA("Color A", Color) = (1,0,0,1)
		_ColorB("Color B", Color) = (0,1,0,1)
		_ColorC("Color C", Color) = (0,0,1,1)
		_AgeMapContrast("Age Map Contrast", Range( -1 , 1)) = 0
		_PaintGlossiness("Paint Glossiness", Range( 0 , 1)) = 0
		_AOLightness("AO Lightness", Range( 0 , 1)) = 0
		_HeightScale("Height Scale", Range( 0 , 0.5)) = 0
		_ReferencePlane("Reference Plane", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _NormalMap;
		uniform sampler2D _MetallicGlossMap;
		uniform float4 _MetallicGlossMap_ST;
		uniform float _HeightScale;
		uniform float _ReferencePlane;
		uniform sampler2D _BaseColor;
		uniform float4 _ColorA;
		uniform float4 _ColorB;
		uniform float4 _ColorC;
		uniform sampler2D _GreyscaleAgeMap;
		uniform float _AgeMapContrast;
		uniform float _PaintGlossiness;
		uniform float _AOLightness;


		inline float2 POM( sampler2D heightMap, float2 uvs, float2 dx, float2 dy, float3 normalWorld, float3 viewWorld, float3 viewDirTan, int minSamples, int maxSamples, float parallax, float refPlane, float2 tilling, float2 curv, int index )
		{
			float3 result = 0;
			int stepIndex = 0;
			int numSteps = ( int )lerp( (float)maxSamples, (float)minSamples, (float)dot( normalWorld, viewWorld ) );
			float layerHeight = 1.0 / numSteps;
			float2 plane = parallax * ( viewDirTan.xy / viewDirTan.z );
			uvs += refPlane * plane;
			float2 deltaTex = -plane * layerHeight;
			float2 prevTexOffset = 0;
			float prevRayZ = 1.0f;
			float prevHeight = 0.0f;
			float2 currTexOffset = deltaTex;
			float currRayZ = 1.0f - layerHeight;
			float currHeight = 0.0f;
			float intersection = 0;
			float2 finalTexOffset = 0;
			while ( stepIndex < numSteps + 1 )
			{
				currHeight = tex2Dgrad( heightMap, uvs + currTexOffset, dx, dy ).b;
				if ( currHeight > currRayZ )
				{
					stepIndex = numSteps + 1;
				}
				else
				{
					stepIndex++;
					prevTexOffset = currTexOffset;
					prevRayZ = currRayZ;
					prevHeight = currHeight;
					currTexOffset += deltaTex;
					currRayZ -= layerHeight;
				}
			}
			int sectionSteps = 2;
			int sectionIndex = 0;
			float newZ = 0;
			float newHeight = 0;
			while ( sectionIndex < sectionSteps )
			{
				intersection = ( prevHeight - prevRayZ ) / ( prevHeight - currHeight + currRayZ - prevRayZ );
				finalTexOffset = prevTexOffset + intersection * deltaTex;
				newZ = prevRayZ - intersection * layerHeight;
				newHeight = tex2Dgrad( heightMap, uvs + finalTexOffset, dx, dy ).b;
				if ( newHeight > newZ )
				{
					currTexOffset = finalTexOffset;
					currHeight = newHeight;
					currRayZ = newZ;
					deltaTex = intersection * deltaTex;
					layerHeight = intersection * layerHeight;
				}
				else
				{
					prevTexOffset = finalTexOffset;
					prevHeight = newHeight;
					prevRayZ = newZ;
					deltaTex = ( 1 - intersection ) * deltaTex;
					layerHeight = ( 1 - intersection ) * layerHeight;
				}
				sectionIndex++;
			}
			return uvs + finalTexOffset;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float2 OffsetPOM61 = POM( _MetallicGlossMap, uv_MetallicGlossMap, ddx(uv_MetallicGlossMap), ddx(uv_MetallicGlossMap), ase_worldNormal, worldViewDir, i.viewDir, 4, 25, _HeightScale, _ReferencePlane, _MetallicGlossMap_ST.xy, float2(0,0), 0.0 );
			o.Normal = UnpackNormal( tex2D( _NormalMap, OffsetPOM61 ) );
			float4 tex2DNode3 = tex2D( _BaseColor, OffsetPOM61 );
			float4 temp_output_16_0 = ( ( ( _ColorA * i.vertexColor.r ) + ( _ColorB * i.vertexColor.g ) ) + ( _ColorC * i.vertexColor.b ) );
			float4 tex2DNode38 = tex2D( _MetallicGlossMap, OffsetPOM61 );
			float temp_output_45_0 = ( ( 1.0 - i.vertexColor.a ) * ( saturate( ( ( temp_output_16_0.a * 5.0 ) * ( ( ( tex2D( _GreyscaleAgeMap, OffsetPOM61 ).g - 0.5 ) * ( _AgeMapContrast * 5.0 ) ) + 0.5 ) ) ) * tex2DNode38.g ) );
			float4 lerpResult54 = lerp( tex2DNode3 , ( tex2DNode3 * saturate( ( temp_output_16_0 + i.vertexColor.a ) ) ) , temp_output_45_0);
			o.Albedo = lerpResult54.rgb;
			o.Metallic = tex2DNode38.r;
			float lerpResult70 = lerp( tex2DNode38.a , _PaintGlossiness , temp_output_45_0);
			o.Smoothness = lerpResult70;
			o.Occlusion = saturate( ( tex2DNode38.g + _AOLightness ) );
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				fixed4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=14301
108;150;1398;819;6213.71;1979.337;3.959149;True;False
Node;AmplifyShaderEditor.CommentaryNode;73;-3264.23,-1785.554;Float;False;1424.809;992.1457;Vertex Colors are applied to meshes. These RGBA colors control where each Color channel in the material gets applied. Alpha of the Color controls brightness of the age map.;12;9;12;13;6;11;14;15;10;16;67;17;21;Channel Application;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;64;-5203.259,-536.4733;Float;True;Property;_MetallicGlossMap;MetallicGlossMap;1;0;Create;True;None;2e5ae0f0a6c32b0478497d1424cff4ad;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;65;-4904.009,-799.3084;Float;False;0;64;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-4892.352,-546.9027;Float;False;Property;_ReferencePlane;Reference Plane;11;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-4915.128,-678.8737;Float;False;Property;_HeightScale;Height Scale;10;0;Create;True;0;0.038;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-3203.438,-1735.554;Float;False;Property;_ColorA;Color A;4;0;Create;True;1,0,0,1;0.7720588,0.2441068,0.2441068,0.559;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-3214.23,-1478.662;Float;False;Property;_ColorB;Color B;5;0;Create;True;0,1,0,1;0,1,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;10;-3187.135,-997.0646;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;61;-4555.041,-635.8065;Float;False;2;4;25;2;0.02;0;False;1,1;False;0,0;False;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT2;0,0;False;6;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;72;-4292.471,-103.3239;Float;False;2127.654;548.5;The age map blends between the underlying basecolor and the painted basecolor. Also controls where the paint smoothness is applied.;16;30;33;35;29;34;28;31;36;68;44;23;69;45;25;46;70;Age Map Composite and Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2894.911,-1384.66;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;14;-3206.522,-1243.769;Float;False;Property;_ColorC;Color C;6;0;Create;True;0,0,1,1;0,0,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-2893.359,-1563.173;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-2820.162,-1234.257;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-2716.397,-1437.437;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;30;-4242.471,-10.57636;Float;True;Property;_GreyscaleAgeMap;Greyscale Age Map;3;0;Create;True;None;271fb32c145eb8845b782feb1e9600a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-4121,245.6922;Float;False;Property;_AgeMapContrast;Age Map Contrast;7;0;Create;True;0;0.12;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-4050.734,330.1761;Float;False;Constant;_Float3;Float 3;7;0;Create;True;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-3960.445,167.6742;Float;False;Constant;_Float1;Float 1;5;0;Create;True;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-3712.172,250.4979;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;28;-3761.685,44.18632;Float;False;2;0;FLOAT;0,0,0,0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-2590.082,-1247.687;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-3510.653,60.02145;Float;False;2;2;0;FLOAT;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;67;-2486.32,-1093.665;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-3353.666,145.3968;Float;False;2;2;0;FLOAT;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-3353.327,-53.32393;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;5.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-3207.907,125.3353;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;38;-4379.583,684.976;Float;True;Property;_Material;Material;2;0;Create;True;None;9fbea323e2eb20e40b95831fdb3b09eb;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;44;-3060.17,132.4937;Float;False;1;0;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-2161.888,-926.4079;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;21;-2014.42,-925.9218;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-2126.275,-688.9584;Float;True;Property;_BaseColor;Base Color;0;0;Create;True;None;dcd17aa8e6585664990774685ce08296;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-2846.333,168.6008;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-2859.755,-45.95015;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-4180.719,923.531;Float;False;Property;_AOLightness;AO Lightness;9;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-2578.39,84.12487;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-3874.352,802.5852;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1716.086,-798.1523;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2674.754,-36.82881;Float;False;Property;_PaintGlossiness;Paint Glossiness;8;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-4242.614,-519.4744;Float;True;Property;_NormalMap;Normal Map;2;0;Create;True;None;30184a478305e3b4183a1daccd53b435;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;71;-1295.771,786.5538;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;70;-2348.818,102.2818;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;54;-1511.686,-587.5571;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-789.0698,-208.0267;Float;False;True;2;Float;;0;0;Standard;Quantum Theory/PBR - Rome Wall Multicolored Parallax;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;65;2;64;0
WireConnection;61;0;65;0
WireConnection;61;1;64;0
WireConnection;61;2;63;0
WireConnection;61;4;62;0
WireConnection;12;0;11;0
WireConnection;12;1;10;2
WireConnection;9;0;6;0
WireConnection;9;1;10;1
WireConnection;15;0;14;0
WireConnection;15;1;10;3
WireConnection;13;0;9;0
WireConnection;13;1;12;0
WireConnection;30;1;61;0
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;28;0;30;2
WireConnection;28;1;29;0
WireConnection;16;0;13;0
WireConnection;16;1;15;0
WireConnection;31;0;28;0
WireConnection;31;1;34;0
WireConnection;67;0;16;0
WireConnection;36;0;31;0
WireConnection;36;1;29;0
WireConnection;25;0;67;3
WireConnection;68;0;25;0
WireConnection;68;1;36;0
WireConnection;38;0;64;0
WireConnection;38;1;61;0
WireConnection;44;0;68;0
WireConnection;17;0;16;0
WireConnection;17;1;10;4
WireConnection;21;0;17;0
WireConnection;3;1;61;0
WireConnection;69;0;44;0
WireConnection;69;1;38;2
WireConnection;23;0;10;4
WireConnection;45;0;23;0
WireConnection;45;1;69;0
WireConnection;51;0;38;2
WireConnection;51;1;52;0
WireConnection;22;0;3;0
WireConnection;22;1;21;0
WireConnection;50;1;61;0
WireConnection;71;0;51;0
WireConnection;70;0;38;4
WireConnection;70;1;46;0
WireConnection;70;2;45;0
WireConnection;54;0;3;0
WireConnection;54;1;22;0
WireConnection;54;2;45;0
WireConnection;0;0;54;0
WireConnection;0;1;50;0
WireConnection;0;3;38;1
WireConnection;0;4;70;0
WireConnection;0;5;71;0
ASEEND*/
//CHKSM=BE22B901847619C64A2749B3199A80B512EDEDF7