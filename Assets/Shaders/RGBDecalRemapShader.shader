// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "custom/RGBRemapShader"
{
	Properties
	{
		_RGBDecal("RGB Decal", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (1,0.6367924,0.9410694,0)
		_RemapRColor("Remap R Color", Color) = (1,0,0,0)
		_RemapGColor("Remap G Color", Color) = (0,1,0,0)
		_RemapBColor("Remap B Color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _RGBDecal;
		uniform float4 _RGBDecal_ST;
		uniform float4 _BaseColor;
		uniform float4 _RemapRColor;
		uniform float4 _RemapGColor;
		uniform float4 _RemapBColor;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_RGBDecal = i.uv_texcoord * _RGBDecal_ST.xy + _RGBDecal_ST.zw;
			float4 tex2DNode4 = tex2D( _RGBDecal, uv_RGBDecal );
			float layeredBlendVar17 = tex2DNode4.a;
			float4 layeredBlend17 = ( lerp( _BaseColor,( ( tex2DNode4.r * tex2DNode4.a * _RemapRColor ) + ( tex2DNode4.g * tex2DNode4.a * _RemapGColor ) + ( tex2DNode4.b * tex2DNode4.a * _RemapBColor ) ) , layeredBlendVar17 ) );
			o.Albedo = layeredBlend17.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18909
30;559;1205;600;1751.336;286.842;2.192989;True;False
Node;AmplifyShaderEditor.SamplerNode;4;-962.9301,-42.74406;Inherit;True;Property;_RGBDecal;RGB Decal;0;0;Create;True;0;0;0;False;0;False;-1;None;df3e5635e17934cf7ade6c7fa1ecc8c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;13;-952.1733,696.4476;Inherit;False;Property;_RemapBColor;Remap B Color;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-953.4579,441.9438;Inherit;False;Property;_RemapGColor;Remap G Color;3;0;Create;True;0;0;0;False;0;False;0,1,0,0;0.1037735,0.1575517,0.4150943,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;6;-958.8014,201.9188;Inherit;False;Property;_RemapRColor;Remap R Color;2;0;Create;True;0;0;0;False;0;False;1,0,0,0;0.3921569,0.372549,0.3372549,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-312.1163,420.7652;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-302.7391,673.949;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-318.2146,176.133;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;12;-936.1242,-298.6951;Inherit;False;Property;_BaseColor;Base Color;1;0;Create;True;0;0;0;False;0;False;1,0.6367924,0.9410694,0;0.7264151,0.6767311,0.627047,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;16;116.8895,400.2703;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LayeredBlendNode;17;488.1031,31.50503;Inherit;True;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;946.0594,29.08323;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;custom/RGBRemapShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;14;0;4;2
WireConnection;14;1;4;4
WireConnection;14;2;7;0
WireConnection;15;0;4;3
WireConnection;15;1;4;4
WireConnection;15;2;13;0
WireConnection;10;0;4;1
WireConnection;10;1;4;4
WireConnection;10;2;6;0
WireConnection;16;0;10;0
WireConnection;16;1;14;0
WireConnection;16;2;15;0
WireConnection;17;0;4;4
WireConnection;17;1;12;0
WireConnection;17;2;16;0
WireConnection;0;0;17;0
ASEEND*/
//CHKSM=2C26879A1D1ED34B1D41E9C6FAA0D79DD95DBFF2