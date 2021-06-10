// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/CarGrill"
{
	Properties
	{
		_Frequency("Frequency", Range( 0.001 , 0.05)) = -0.4
		_BaseColor("Base Color", Color) = (0,0,0,0)
		_HighlightOffset("Highlight Offset", Float) = 0
		_HighlightStrength("Highlight Strength", Float) = 0
		_HighlightColor("Highlight Color", Color) = (0.8396226,0.6735973,0.368325,1)
		_GrillDirection("Grill Direction", Vector) = (0,0,1,0)
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
			float3 worldPos;
		};

		uniform float3 _GrillDirection;
		uniform float _Frequency;
		uniform float _HighlightOffset;
		uniform float _HighlightStrength;
		uniform float4 _BaseColor;
		uniform float4 _HighlightColor;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float dotResult26 = dot( _GrillDirection , ase_worldPos );
			float temp_output_6_0 = ( dotResult26 / _Frequency );
			float temp_output_11_0 = cos( ( temp_output_6_0 + _HighlightOffset ) );
			float layeredBlendVar15 = ( temp_output_11_0 * _HighlightStrength );
			float4 layeredBlend15 = ( lerp( ( _BaseColor * cos( temp_output_6_0 ) ),( _HighlightColor * temp_output_11_0 ) , layeredBlendVar15 ) );
			o.Albedo = layeredBlend15.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18909
30;559;1205;600;942.0817;511.9248;1.081604;True;False
Node;AmplifyShaderEditor.Vector3Node;25;-342.8185,-407.0635;Inherit;False;Property;_GrillDirection;Grill Direction;5;0;Create;True;0;0;0;False;0;False;0,0,1;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-395.8714,-99.8335;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;5;-234.4605,20.34178;Inherit;False;Property;_Frequency;Frequency;0;0;Create;True;0;0;0;False;0;False;-0.4;0.01;0.001;0.05;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;26;-88.29858,-224.2536;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-162.3559,190.7254;Inherit;False;Property;_HighlightOffset;Highlight Offset;2;0;Create;True;0;0;0;False;0;False;0;4.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;85.30597,-139.0448;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;166.7542,114.3795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;418.7248,-539.7344;Inherit;False;Property;_BaseColor;Base Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;13;222.5245,-349.066;Inherit;False;Property;_HighlightColor;Highlight Color;4;0;Create;True;0;0;0;False;0;False;0.8396226,0.6735973,0.368325,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CosOpNode;11;378.2419,117.3581;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;1;344.2891,-134.5372;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;729.7062,-188.9126;Inherit;False;Property;_HighlightStrength;Highlight Strength;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;1040.96,-110.2937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;814.1849,-511.0154;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;1046.783,12.14087;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LayeredBlendNode;15;1313.447,-367.517;Inherit;True;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1679.81,-267.3397;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/CarGrill;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;25;0
WireConnection;26;1;35;0
WireConnection;6;0;26;0
WireConnection;6;1;5;0
WireConnection;9;0;6;0
WireConnection;9;1;10;0
WireConnection;11;0;9;0
WireConnection;1;0;6;0
WireConnection;18;0;11;0
WireConnection;18;1;19;0
WireConnection;8;0;7;0
WireConnection;8;1;1;0
WireConnection;12;0;13;0
WireConnection;12;1;11;0
WireConnection;15;0;18;0
WireConnection;15;1;8;0
WireConnection;15;2;12;0
WireConnection;0;0;15;0
ASEEND*/
//CHKSM=52C81F2D0B6299227D45EF342C53C2C12B10F5C7