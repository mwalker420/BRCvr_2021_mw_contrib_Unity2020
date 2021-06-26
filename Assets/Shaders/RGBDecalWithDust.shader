// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/RGBDecalWithDust"
{
	Properties
	{
		_RGBDecal("RGB Decal", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (1,0.6367924,0.9410694,0)
		_RemapRColor("Remap R Color", Color) = (1,0,0,0)
		_DustColor("Dust Color", Color) = (1,0.8705882,0.6666667,0)
		_RemapGColor("Remap G Color", Color) = (0,1,0,0)
		_DustCoverage("DustCoverage", Range( 0 , 1)) = 1
		_RemapBColor("Remap B Color", Color) = (0,0,0,0)
		_NoiseScaleDust("NoiseScale (Dust)", Range( 0 , 300)) = 86.644
		_NoiseContrast("Noise Contrast", Range( 0.01 , 20)) = 5.5715
		_NoiseMin("Noise Min", Range( 0 , 1)) = 0.9058824
		_NoiseMax("Noise Max", Range( 0 , 1)) = 1
		_DustDirectionNormal("DustDirectionNormal", Vector) = (0,1,0,0)
		_BaseCarMetallic(" Base Car Metallic", Range( 0 , 4)) = 0
		_BaseCarSmoothess("Base Car Smoothess", Range( -1 , 1)) = -1
		_FresnelProps("Fresnel Props", Vector) = (0,0,0,0)
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
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float _NoiseScaleDust;
		uniform float _NoiseMin;
		uniform float _NoiseMax;
		uniform float3 _DustDirectionNormal;
		uniform float _DustCoverage;
		uniform float _NoiseContrast;
		uniform sampler2D _RGBDecal;
		uniform float4 _RGBDecal_ST;
		uniform float4 _BaseColor;
		uniform float4 _RemapRColor;
		uniform float4 _RemapGColor;
		uniform float4 _RemapBColor;
		uniform float4 _DustColor;
		uniform float _BaseCarMetallic;
		uniform float3 _FresnelProps;
		uniform float _BaseCarSmoothess;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 rotatedValue8 = RotateAroundAxis( float3( 0,0,0 ), ase_worldPos, float3( 1,0,0 ), 90.0 );
			float simplePerlin3D15 = snoise( rotatedValue8*_NoiseScaleDust );
			simplePerlin3D15 = simplePerlin3D15*0.5 + 0.5;
			float3 ase_worldNormal = i.worldNormal;
			float dotResult4 = dot( _DustDirectionNormal , ase_worldNormal );
			float temp_output_18_0 = ( (_NoiseMin + (simplePerlin3D15 - 0.0) * (_NoiseMax - _NoiseMin) / (1.0 - 0.0)) * pow( ( ( ( dotResult4 + 1.0 ) / 2.0 ) * _DustCoverage ) , _NoiseContrast ) );
			float DirectionalDust20 = temp_output_18_0;
			float2 uv_RGBDecal = i.uv_texcoord * _RGBDecal_ST.xy + _RGBDecal_ST.zw;
			float4 tex2DNode43 = tex2D( _RGBDecal, uv_RGBDecal );
			float layeredBlendVar52 = tex2DNode43.a;
			float4 layeredBlend52 = ( lerp( _BaseColor,( ( tex2DNode43.r * tex2DNode43.a * _RemapRColor ) + ( tex2DNode43.g * tex2DNode43.a * _RemapGColor ) + ( tex2DNode43.b * tex2DNode43.a * _RemapBColor ) ) , layeredBlendVar52 ) );
			float4 RGBDecalVar54 = layeredBlend52;
			float layeredBlendVar41 = DirectionalDust20;
			float4 layeredBlend41 = ( lerp( RGBDecalVar54,_DustColor , layeredBlendVar41 ) );
			o.Albedo = layeredBlend41.rgb;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV29 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode29 = ( _FresnelProps.x + _FresnelProps.y * pow( 1.0 - fresnelNdotV29, _FresnelProps.z ) );
			o.Metallic = saturate( ( ( -DirectionalDust20 + _BaseCarMetallic ) - fresnelNode29 ) );
			o.Smoothness = saturate( ( ( -DirectionalDust20 + _BaseCarSmoothess ) - fresnelNode29 ) );
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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18909
0;559;1224;600;2045.862;1720.92;2.035002;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-1050.307,-86.04052;Inherit;False;1888.326;813.4345;Dust;19;42;20;18;17;16;15;14;13;12;11;10;9;8;7;6;5;4;3;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;3;-1021.647,311.0534;Inherit;False;Property;_DustDirectionNormal;DustDirectionNormal;11;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;2;-1023.138,464.2357;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;4;-703.4019,401.0414;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-1012.431,38.43892;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-464.9622,409.5309;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-756.6231,138.0382;Inherit;False;Property;_NoiseScaleDust;NoiseScale (Dust);7;0;Create;True;0;0;0;False;0;False;86.644;105.682;0;300;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-495.6874,614.5104;Inherit;False;Property;_DustCoverage;DustCoverage;5;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;-333.1501,409.5309;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;8;-778.2801,-36.04046;Inherit;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;90;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-166.0847,613.0734;Inherit;False;Property;_NoiseContrast;Noise Contrast;8;0;Create;True;0;0;0;False;0;False;5.5715;5.3;0.01;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-376.9301,284.9966;Inherit;False;Property;_NoiseMax;Noise Max;10;0;Create;True;0;0;0;False;0;False;1;0.9351386;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;15;-360.5661,-29.86873;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-135.4774,374.0396;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-379.3213,204.2231;Inherit;False;Property;_NoiseMin;Noise Min;9;0;Create;True;0;0;0;False;0;False;0.9058824;0.7623329;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;16;-28.36249,64.84358;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;17;154.5341,431.8201;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;-1251.845,-1656.33;Inherit;False;1671.507;1276.644;RGB Decal;11;43;44;45;46;47;48;49;50;51;52;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;44;-1191.088,-611.1874;Inherit;False;Property;_RemapBColor;Remap B Color;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;46;-1197.716,-1105.716;Inherit;False;Property;_RemapRColor;Remap R Color;2;0;Create;True;0;0;0;False;0;False;1,0,0,0;0.3921568,0.372549,0.3372549,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;45;-1192.373,-865.6907;Inherit;False;Property;_RemapGColor;Remap G Color;4;0;Create;True;0;0;0;False;0;False;0,1,0,0;0.1037735,0.1575516,0.4150943,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;43;-1201.845,-1350.379;Inherit;True;Property;_RGBDecal;RGB Decal;0;0;Create;True;0;0;0;False;0;False;-1;None;df3e5635e17934cf7ade6c7fa1ecc8c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;358.7896,42.67122;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-551.0309,-886.8694;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;607.7497,38.18254;Inherit;True;DirectionalDust;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-541.6534,-633.6859;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-557.129,-1131.502;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;743.906,-421.5514;Inherit;True;20;DirectionalDust;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;50;-1175.039,-1606.33;Inherit;False;Property;_BaseColor;Base Color;1;0;Create;True;0;0;0;False;0;False;1,0.6367924,0.9410694,0;0.7264151,0.6767311,0.627047,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;23;1217.394,365.7892;Inherit;False;Property;_FresnelProps;Fresnel Props;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0.29,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-122.0255,-907.3643;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;29;1464.905,334.3461;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.23;False;3;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;1012.185,72.93967;Inherit;False;Property;_BaseCarSmoothess;Base Car Smoothess;13;0;Create;True;0;0;0;False;0;False;-1;0.3799876;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;1024.905,-106.5172;Inherit;False;Property;_BaseCarMetallic; Base Car Metallic;12;0;Create;True;0;0;0;False;0;False;0;1.049224;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;27;1079.307,-394.9254;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LayeredBlendNode;52;116.6619,-1364.481;Inherit;True;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchNode;33;1734.895,207.5211;Inherit;False;0;2;8;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;1440.016,-400.0916;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;197.7747,-1056.702;Inherit;False;RGBDecalVar;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;1423.601,-70.32321;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;1858.191,-152.7401;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;1733.776,-456.8178;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;783.09,-681.2163;Inherit;False;Property;_DustColor;Dust Color;3;0;Create;True;0;0;0;False;0;False;1,0.8705882,0.6666667,0;1,0.8705882,0.6666667,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;36;646.6839,-851.7798;Inherit;True;54;RGBDecalVar;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;40;2101.063,-208.9302;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;39;2058.305,-460.0443;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LayeredBlendNode;41;1340.212,-709.6546;Inherit;True;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FractNode;42;623.0517,373.2744;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2813.274,-510.7332;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/RGBDecalWithDust;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;4;1;2;0
WireConnection;6;0;4;0
WireConnection;7;0;6;0
WireConnection;8;3;5;0
WireConnection;15;0;8;0
WireConnection;15;1;9;0
WireConnection;11;0;7;0
WireConnection;11;1;10;0
WireConnection;16;0;15;0
WireConnection;16;3;12;0
WireConnection;16;4;14;0
WireConnection;17;0;11;0
WireConnection;17;1;13;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;47;0;43;2
WireConnection;47;1;43;4
WireConnection;47;2;45;0
WireConnection;20;0;18;0
WireConnection;48;0;43;3
WireConnection;48;1;43;4
WireConnection;48;2;44;0
WireConnection;49;0;43;1
WireConnection;49;1;43;4
WireConnection;49;2;46;0
WireConnection;51;0;49;0
WireConnection;51;1;47;0
WireConnection;51;2;48;0
WireConnection;29;1;23;1
WireConnection;29;2;23;2
WireConnection;29;3;23;3
WireConnection;27;0;21;0
WireConnection;52;0;43;4
WireConnection;52;1;50;0
WireConnection;52;2;51;0
WireConnection;33;0;29;0
WireConnection;31;0;27;0
WireConnection;31;1;26;0
WireConnection;54;0;52;0
WireConnection;34;0;27;0
WireConnection;34;1;30;0
WireConnection;38;0;34;0
WireConnection;38;1;33;0
WireConnection;35;0;31;0
WireConnection;35;1;33;0
WireConnection;40;0;38;0
WireConnection;39;0;35;0
WireConnection;41;0;21;0
WireConnection;41;1;36;0
WireConnection;41;2;37;0
WireConnection;42;0;18;0
WireConnection;0;0;41;0
WireConnection;0;3;39;0
WireConnection;0;4;40;0
ASEEND*/
//CHKSM=A84FD316CECD1B7FA7D609E37BC024D7778C636E