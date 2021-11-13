// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Quantum Theory/PBR - Decor Decal"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.65
		_Color("Color", Color) = (0,0,0,0)
		_MainTex("MainTex", 2D) = "white" {}
		_Material("Material", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_DetailNormal("Detail Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		_DetailNormalScale("Detail Normal Scale", Range( -2 , 2)) = 1
		_DetailTiling("Detail Tiling", Range( 1 , 50)) = 1
		_StainCleanup("Stain Cleanup", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Back
		Offset  -2 , 3
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _DetailNormal;
		uniform float _DetailNormalScale;
		uniform float _DetailTiling;
		uniform float _NormalScale;
		uniform sampler2D _Normal;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Color;
		uniform float _StainCleanup;
		uniform sampler2D _Material;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _Cutoff = 0.65;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord42 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float3 tex2DNode35 = UnpackScaleNormal( tex2D( _DetailNormal, ( uv_TexCoord42 * _DetailTiling ) ) ,_DetailNormalScale );
			float3 tex2DNode7 = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord42 ) ,_NormalScale );
			float3 appendResult51 = (float3(( tex2DNode35.r + tex2DNode7.r ) , ( tex2DNode35.g + tex2DNode7.g ) , ( tex2DNode35.b * tex2DNode7.b )));
			float3 normalizeResult39 = normalize( appendResult51 );
			o.Normal = normalizeResult39;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _Material, uv_TexCoord42 );
			float temp_output_58_0 = saturate( ( _StainCleanup + tex2DNode1.g ) );
			o.Albedo = ( ( tex2D( _MainTex, uv_MainTex ) * ( _Color * 2.0 ) ) * temp_output_58_0 ).rgb;
			o.Metallic = _Metallic;
			float temp_output_3_0 = ( 1.0 - temp_output_58_0 );
			o.Smoothness = saturate( ( _Smoothness - temp_output_3_0 ) );
			o.Occlusion = 1.0;
			o.Alpha = 1;
			clip( saturate( ( temp_output_3_0 + ( tex2DNode1.b * 100.0 ) ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=14301
108;150;1398;819;2224.18;1402.033;2.382722;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;41;-1621.663,-740.709;Float;True;Property;_Material;Material;3;0;Create;True;None;20edff3bae9c5d948a5f98686c8cb849;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-1655.041,-451.2527;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;-1202.342,-981.5911;Float;False;Property;_StainCleanup;Stain Cleanup;9;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1657.398,-288.8963;Float;False;Property;_DetailTiling;Detail Tiling;8;0;Create;True;1;8;1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1221.31,-625.9868;Float;True;Property;_mat;mat;4;0;Create;True;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;53;-1503.706,88.97556;Float;False;1337.108;573.7729;Setup for Normal and Detail Normals;10;35;36;37;7;48;49;50;51;39;65;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1323.977,-374.5196;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;36;-1470.04,132.845;Float;True;Property;_DetailNormal;Detail Normal;5;0;Create;True;None;46138ca1a836c4a45873f7a1a99ed0e6;True;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1464.472,534.1936;Float;False;Property;_NormalScale;Normal Scale;6;0;Create;True;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-834.4423,-985.5093;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1453.706,359.1618;Float;False;Property;_DetailNormalScale;Detail Normal Scale;7;0;Create;True;1;1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;-679.6147,-971.5796;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;35;-1122.194,188.834;Float;True;Property;_dn;dn;5;0;Create;True;None;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-950.2847,-1404.893;Float;False;Constant;_Float0;Float 0;13;0;Create;True;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;34;-1360.273,-1723.386;Float;True;Property;_MainTex;MainTex;2;0;Create;True;None;d4153fc52f75e9d4eb88335fdb9e9924;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.ColorNode;22;-1338.118,-1520.153;Float;False;Property;_Color;Color;1;0;Create;True;0,0,0,0;0.721,0.721,0.721,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1140.979,432.7481;Float;True;Property;_Normal;Normal;4;0;Create;True;None;cf7a68aeea97b0d45a82f25bf8cd625c;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-881.3832,-553.091;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;100.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-794.3109,-1518.326;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;2,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-718.5209,-109.7989;Float;False;Property;_Smoothness;Smoothness;10;0;Create;True;0;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-756.3629,251.6366;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;3;-508.482,-737.0934;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-591.8189,488.7702;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-1124.973,-1724.431;Float;True;Property;_nothin;nothin;1;0;Create;True;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-708.9612,384.5767;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-299.203,-564.5215;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;-481.183,305.8836;Float;False;FLOAT3;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-633.0304,-1715.108;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-379.6316,-203.6026;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;74.83698,331.8042;Float;False;Constant;_NoAO;No AO;6;0;Create;True;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;39;-333.2655,308.855;Float;False;1;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-11.02889,-12.25823;Float;False;Property;_Metallic;Metallic;11;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;62;-7.749834,90.41492;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-462.7325,-1414.499;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;6;-178.6432,-552.1284;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;339,-9;Float;False;True;2;Float;;0;0;Standard;Quantum Theory/PBR - Decor Decal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;True;-2;3;False;0;Custom;0.65;True;False;0;True;Opaque;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;0;41;0
WireConnection;1;1;42;0
WireConnection;69;0;42;0
WireConnection;69;1;68;0
WireConnection;57;0;56;0
WireConnection;57;1;1;2
WireConnection;58;0;57;0
WireConnection;35;0;36;0
WireConnection;35;1;69;0
WireConnection;35;5;37;0
WireConnection;7;1;42;0
WireConnection;7;5;65;0
WireConnection;4;0;1;3
WireConnection;66;0;22;0
WireConnection;66;1;67;0
WireConnection;48;0;35;1
WireConnection;48;1;7;1
WireConnection;3;0;58;0
WireConnection;50;0;35;3
WireConnection;50;1;7;3
WireConnection;2;0;34;0
WireConnection;49;0;35;2
WireConnection;49;1;7;2
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;51;0;48;0
WireConnection;51;1;49;0
WireConnection;51;2;50;0
WireConnection;21;0;2;0
WireConnection;21;1;66;0
WireConnection;63;0;59;0
WireConnection;63;1;3;0
WireConnection;39;0;51;0
WireConnection;62;0;63;0
WireConnection;9;0;21;0
WireConnection;9;1;58;0
WireConnection;6;0;5;0
WireConnection;0;0;9;0
WireConnection;0;1;39;0
WireConnection;0;3;64;0
WireConnection;0;4;62;0
WireConnection;0;5;14;0
WireConnection;0;10;6;0
ASEEND*/
//CHKSM=D74D4441F889FAFA20ECA0DE4993A1A623184EFF