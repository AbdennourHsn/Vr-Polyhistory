// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Quantum Theory/PBR - Parallax Mapping Puddle Decal"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_MetallicGlossMap("MetallicGlossMap", 2D) = "white" {}
		_BumpMap("BumpMap", 2D) = "white" {}
		_StainPower("Stain Power", Range( 1 , 3)) = 0
		_AOFade("AO Fade", Range( 0 , 1)) = 0
		_NormalStrength("Normal Strength", Range( 0 , 1)) = 0
		_HeightScale("Height Scale", Range( 0 , 0.5)) = 0
		_StainSmoothnessLimit("Stain Smoothness Limit", Range( 0 , 1)) = 0.5
		_ReferencePlane("Reference Plane", Range( 0 , 1)) = 0
		_PuddleColor("Puddle Color", Color) = (0.2941177,0.2392157,0.1921569,0)
		_PuddleMinHeight("Puddle Min Height", Range( 0 , 1)) = 0
		_PuddleFalloff("Puddle Falloff", Range( 0.0001 , 1)) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "ForceNoShadowCasting" = "True" }
		Cull Back
		Offset  -2 , -2
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha 
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float4 vertexColor : COLOR;
		};

		uniform float _NormalStrength;
		uniform sampler2D _BumpMap;
		uniform sampler2D _MetallicGlossMap;
		uniform float4 _MetallicGlossMap_ST;
		uniform float _HeightScale;
		uniform float _ReferencePlane;
		uniform float _PuddleMinHeight;
		uniform float _PuddleFalloff;
		uniform float4 _PuddleColor;
		uniform sampler2D _MainTex;
		uniform float _StainPower;
		uniform float _StainSmoothnessLimit;
		uniform float _AOFade;
		uniform float _Cutoff = 0.5;


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
			float3 tex2DNode2 = UnpackScaleNormal( tex2D( _BumpMap, OffsetPOM5 ) ,_NormalStrength );
			float4 tex2DNode9 = tex2D( _MetallicGlossMap, OffsetPOM5 );
			float temp_output_24_0 = ( 1.0 - i.vertexColor.b );
			float temp_output_26_0 = ( _PuddleMinHeight * temp_output_24_0 );
			float lerpResult34 = lerp( ( pow( ( ( tex2DNode9.b - temp_output_26_0 ) / ( 1.0 - temp_output_26_0 ) ) , _PuddleFalloff ) + 0.2 ) , 1.0 , i.vertexColor.b);
			float temp_output_57_0 = saturate( lerpResult34 );
			float4 appendResult51 = (float4(( tex2DNode2.r * temp_output_57_0 ) , ( tex2DNode2.g * temp_output_57_0 ) , tex2DNode2.b , 0.0));
			float4 normalizeResult52 = normalize( appendResult51 );
			o.Normal = normalizeResult52.xyz;
			float4 temp_cast_1 = (( ( ( 1.0 - _StainPower ) * i.vertexColor.r ) + _StainPower )).xxxx;
			float4 lerpResult36 = lerp( _PuddleColor , pow( tex2D( _MainTex, OffsetPOM5 ) , temp_cast_1 ) , temp_output_57_0);
			o.Albedo = lerpResult36.rgb;
			o.Metallic = tex2DNode9.r;
			o.Smoothness = ( ( 1.0 - ( ( 1.0 - tex2DNode9.a ) * ( temp_output_57_0 + 0.1 ) ) ) + ( _StainSmoothnessLimit * ( 1.0 - i.vertexColor.a ) ) );
			o.Occlusion = saturate( ( ( temp_output_24_0 + tex2DNode9.g ) + _AOFade ) );
			o.Alpha = 1;
			clip( ( ( tex2DNode9.b + 0.5 ) * i.vertexColor.g ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=14301
108;150;1398;819;3021.884;1423.096;3.031228;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;4;-1641.912,-15.99317;Float;True;Property;_MetallicGlossMap;MetallicGlossMap;1;0;Create;True;None;None;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.VertexColorNode;15;-2034.157,398.8445;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;27;-1949.07,723.2291;Float;False;543.681;302.7138;Minimum height for the puddle;3;24;26;25;Min Height;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1400.465,116.3414;Float;False;Property;_HeightScale;Height Scale;6;0;Create;True;0;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1403.764,201.3389;Float;False;Property;_ReferencePlane;Reference Plane;8;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1361.735,-94.76926;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1899.07,773.2291;Float;False;Property;_PuddleMinHeight;Puddle Min Height;10;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;-1832.244,871.722;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxOcclusionMappingNode;5;-1068.162,49.46777;Float;False;2;4;25;2;0.02;0;False;1,1;False;0,0;False;7;0;FLOAT2;0,0;False;1;SAMPLER2D;;False;2;FLOAT;0.02;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT2;0,0;False;6;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;9;-764.5912,-20.02055;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;35;-1349.38,755.0781;Float;False;1056.248;413.3023;Creating the Final Mask based on the height and where we painted Blue vertex color;7;28;29;30;31;32;33;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1574.389,892.9429;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;-1300.924,957.5874;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-1287.169,823.0932;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;30;-1114.171,827.4662;Float;True;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1195.581,1053.38;Float;False;Property;_PuddleFalloff;Puddle Falloff;11;0;Create;True;0;0;0.0001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;31;-817.0206,821.3604;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-656.2345,829.5012;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1356.821,-1478.167;Float;False;1360.233;622.9132;Blending between stains from Red vertex color channel, the base color, and the puddle color.;8;36;16;38;1;19;18;17;13;baseColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1306.821,-1170.027;Float;False;Property;_StainPower;Stain Power;3;0;Create;True;0;0;1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;34;-560.2144,951.8113;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;1.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;-728.9741,-665.9975;Float;False;1035.607;355.6729;Blend between a normal map and a version with 0 intensity where puddles lie. No lerp!;5;2;51;49;50;52;puddle normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;17;-1071.789,-1269.323;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1020.509,-568.0611;Float;False;Property;_NormalStrength;Normal Strength;5;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;57;-407.0211,927.548;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;47;-157.2021,587.0671;Float;False;737.0297;618.2518;Smoothness of the puddles.;8;40;41;39;42;46;14;21;62;Smoothness;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-893.4816,-1194.073;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;39;-61.85748,872.7655;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-678.9741,-615.9975;Float;True;Property;_BumpMap;BumpMap;2;0;Create;True;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-41.1632,962.4405;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;103.6965,904.9565;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-236.413,-613.1757;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;21;-28.87123,637.0671;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-107.202,752.8993;Float;False;Property;_StainSmoothnessLimit;Stain Smoothness Limit;7;0;Create;True;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-854.8704,-1085.254;Float;True;Property;_MainTex;MainTex;0;0;Create;True;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;54;61.41764,95.20689;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-57.36839,193.1531;Float;False;Property;_AOFade;AO Fade;4;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-227.7306,-443.3246;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-726.6397,-1188.676;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;42;250.8558,916.4532;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;207.037,708.4105;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;-53.59909,-549.8303;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;38;-474.3152,-1428.167;Float;False;Property;_PuddleColor;Puddle Color;9;0;Create;True;0.2941177,0.2392157,0.1921569,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;16;-528.8041,-1202.424;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;243.1885,82.91518;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;71.98117,387.3485;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;425.8273,841.3647;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;52;121.6323,-494.168;Float;False;1;0;FLOAT4;0.0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;233.6824,428.7119;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;11;384.4769,86.61749;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;36;-204.6953,-1218.398;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;732.5793,-66.29617;Float;False;True;2;Float;;0;0;Standard;Quantum Theory/PBR - Parallax Mapping Puddle Decal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;Back;0;0;True;-2;-2;False;0;Custom;0.5;True;False;0;True;Opaque;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;12;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;2;4;0
WireConnection;24;0;15;3
WireConnection;5;0;6;0
WireConnection;5;1;4;0
WireConnection;5;2;7;0
WireConnection;5;4;20;0
WireConnection;9;0;4;0
WireConnection;9;1;5;0
WireConnection;26;0;25;0
WireConnection;26;1;24;0
WireConnection;28;0;26;0
WireConnection;29;0;9;3
WireConnection;29;1;26;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;33;0;31;0
WireConnection;34;0;33;0
WireConnection;34;2;15;3
WireConnection;17;0;13;0
WireConnection;57;0;34;0
WireConnection;18;0;17;0
WireConnection;18;1;15;1
WireConnection;39;0;9;4
WireConnection;2;1;5;0
WireConnection;2;5;8;0
WireConnection;41;0;57;0
WireConnection;40;0;39;0
WireConnection;40;1;41;0
WireConnection;49;0;2;1
WireConnection;49;1;57;0
WireConnection;21;0;15;4
WireConnection;1;1;5;0
WireConnection;54;0;24;0
WireConnection;54;1;9;2
WireConnection;50;0;2;2
WireConnection;50;1;57;0
WireConnection;19;0;18;0
WireConnection;19;1;13;0
WireConnection;42;0;40;0
WireConnection;62;0;14;0
WireConnection;62;1;21;0
WireConnection;51;0;49;0
WireConnection;51;1;50;0
WireConnection;51;2;2;3
WireConnection;16;0;1;0
WireConnection;16;1;19;0
WireConnection;12;0;54;0
WireConnection;12;1;10;0
WireConnection;60;0;9;3
WireConnection;46;0;42;0
WireConnection;46;1;62;0
WireConnection;52;0;51;0
WireConnection;61;0;60;0
WireConnection;61;1;15;2
WireConnection;11;0;12;0
WireConnection;36;0;38;0
WireConnection;36;1;16;0
WireConnection;36;2;57;0
WireConnection;0;0;36;0
WireConnection;0;1;52;0
WireConnection;0;3;9;1
WireConnection;0;4;46;0
WireConnection;0;5;11;0
WireConnection;0;10;61;0
ASEEND*/
//CHKSM=5C73C6545D17A8E0CD9DFCAF000A1389152DBB82