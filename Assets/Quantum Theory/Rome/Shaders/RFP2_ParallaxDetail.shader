// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Quantum Theory/PBR - Parallax Mapping Detail"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_MetallicGlossMap("MetallicGlossMap", 2D) = "white" {}
		_BumpMap("BumpMap", 2D) = "white" {}
		_DetailNormal("Detail Normal", 2D) = "bump" {}
		_StainPower("Stain Power", Range( 1 , 3)) = 0
		_AOFade("AO Fade", Range( 0 , 1)) = 0
		_NormalStrength("Normal Strength", Range( 0 , 1)) = 0
		_DetailNormalScale("Detail Normal Scale", Range( -2 , 2)) = 1
		_DetailTiling("Detail Tiling", Range( 1 , 50)) = 4
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
		#include "UnityStandardUtils.cginc"
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

		uniform sampler2D _DetailNormal;
		uniform float _DetailNormalScale;
		uniform sampler2D _MetallicGlossMap;
		uniform float4 _MetallicGlossMap_ST;
		uniform float _HeightScale;
		uniform float _ReferencePlane;
		uniform float _DetailTiling;
		uniform float _NormalStrength;
		uniform sampler2D _BumpMap;
		uniform sampler2D _MainTex;
		uniform float _StainPower;
		uniform float _AOFade;


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
			float2 OffsetPOM5 = POM( _MetallicGlossMap, uv_MetallicGlossMap, ddx(uv_MetallicGlossMap), ddx(uv_MetallicGlossMap), ase_worldNormal, worldViewDir, i.viewDir, 4, 25, _HeightScale, _ReferencePlane, _MetallicGlossMap_ST.xy, float2(0,0), 0.0 );
			float3 tex2DNode25 = UnpackScaleNormal( tex2D( _DetailNormal, ( OffsetPOM5 * _DetailTiling ) ) ,_DetailNormalScale );
			float3 tex2DNode2 = UnpackScaleNormal( tex2D( _BumpMap, OffsetPOM5 ) ,_NormalStrength );
			float4 appendResult31 = (float4(( tex2DNode25.r + tex2DNode2.r ) , ( tex2DNode25.g + tex2DNode2.g ) , ( tex2DNode25.b * tex2DNode2.b ) , 0.0));
			float4 normalizeResult33 = normalize( appendResult31 );
			o.Normal = normalizeResult33.xyz;
			float4 temp_cast_1 = (( ( ( 1.0 - _StainPower ) * i.vertexColor.r ) + _StainPower )).xxxx;
			o.Albedo = pow( tex2D( _MainTex, OffsetPOM5 ) , temp_cast_1 ).rgb;
			float4 tex2DNode9 = tex2D( _MetallicGlossMap, OffsetPOM5 );
			o.Metallic = tex2DNode9.r;
			o.Smoothness = ( ( 0.5 + ( 1.0 - i.vertexColor.a ) ) * tex2DNode9.a );
			o.Occlusion = saturate( ( tex2DNode9.g + _AOFade ) );
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
108;150;1398;819;3754.332;1527.252;2.952776;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;4;-2266.542,-159.5863;Float;True;Property;_MetallicGlossMap;MetallicGlossMap;1;0;Create;True;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2017.458,-281.1228;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-2116.924,131.1355;Float;False;Property;_ReferencePlane;Reference Plane;10;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2096.11,45.91589;Float;False;Property;_HeightScale;Height Scale;9;0;Create;True;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1738.924,475.0031;Float;False;Property;_DetailTiling;Detail Tiling;8;0;Create;True;4;0;1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;5;-1752.622,-144.3829;Float;False;2;4;25;2;0.02;0;False;1,1;False;0,0;False;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT2;0,0;False;6;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1745.353,171.1207;Float;False;Property;_NormalStrength;Normal Strength;6;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1030.99,-759.0099;Float;False;Property;_StainPower;Stain Power;4;0;Create;True;0;0;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;24;-1716.313,591.9534;Float;True;Property;_DetailNormal;Detail Normal;3;0;Create;True;None;None;False;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1406.992,510.1275;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0.0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1591.768,968.8912;Float;False;Property;_DetailNormalScale;Detail Normal Scale;7;0;Create;True;1;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;15;-793.6833,-491.7935;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;-1225.504,594.0618;Float;True;Property;_DN;DN;1;0;Create;True;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;17;-757.0121,-814.011;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1271.219,-62.64624;Float;True;Property;_BumpMap;BumpMap;2;0;Create;True;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;21;-597.382,-413.0141;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-766.2544,728.6994;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-714.5851,-587.828;Float;False;Constant;_StainSmoothnessLimit;Stain Smoothness Limit;7;0;Create;True;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-620.5177,497.6996;Float;False;Property;_AOFade;AO Fade;5;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-552.8992,-793.0216;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-1270.166,137.8293;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-759.6039,582.3868;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-763.8528,836.8516;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-405.2029,-774.6996;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-551.2926,710.519;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1;-1284.572,-273.0678;Float;True;Property;_MainTex;MainTex;0;0;Create;True;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-324.6762,378.8566;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-405.6933,-421.8098;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-217.8659,104.922;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;11;-168.9569,373.2938;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;16;-233.9524,-260.6107;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;33;-377.0571,711.9751;Float;False;1;0;FLOAT4;0.0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;131.3,-50.7;Float;False;True;2;Float;;0;0;Standard;Quantum Theory/PBR - Parallax Mapping Detail;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;2;4;0
WireConnection;5;0;6;0
WireConnection;5;1;4;0
WireConnection;5;2;7;0
WireConnection;5;4;20;0
WireConnection;35;0;5;0
WireConnection;35;1;34;0
WireConnection;25;0;24;0
WireConnection;25;1;35;0
WireConnection;25;5;26;0
WireConnection;17;0;13;0
WireConnection;2;1;5;0
WireConnection;2;5;8;0
WireConnection;21;0;15;4
WireConnection;30;0;25;2
WireConnection;30;1;2;2
WireConnection;18;0;17;0
WireConnection;18;1;15;1
WireConnection;9;0;4;0
WireConnection;9;1;5;0
WireConnection;29;0;25;1
WireConnection;29;1;2;1
WireConnection;32;0;25;3
WireConnection;32;1;2;3
WireConnection;19;0;18;0
WireConnection;19;1;13;0
WireConnection;31;0;29;0
WireConnection;31;1;30;0
WireConnection;31;2;32;0
WireConnection;1;1;5;0
WireConnection;12;0;9;2
WireConnection;12;1;10;0
WireConnection;22;0;14;0
WireConnection;22;1;21;0
WireConnection;23;0;22;0
WireConnection;23;1;9;4
WireConnection;11;0;12;0
WireConnection;16;0;1;0
WireConnection;16;1;19;0
WireConnection;33;0;31;0
WireConnection;0;0;16;0
WireConnection;0;1;33;0
WireConnection;0;3;9;1
WireConnection;0;4;23;0
WireConnection;0;5;11;0
ASEEND*/
//CHKSM=015C8CFC746CAE23FD1C3482D45358ED32C8FCF7