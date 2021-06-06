// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/DigitalDust"
{
	Properties
	{
		_BaseColor("Base Color", Color) = (0.509434,0.509434,0.509434,0)
		_Texture("Texture", 2D) = "gray" {}
		_ColorVsTextureBlend("ColorVsTextureBlend", Range( 0 , 1)) = 0
		_DustColor("Dust Color", Color) = (1,0.8705882,0.6666667,0)
		_DustCoverage("DustCoverage", Range( 0 , 1)) = 1
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
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
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
		uniform float4 _BaseColor;
		uniform sampler2D _Texture;
		uniform float4 _Texture_ST;
		uniform float _ColorVsTextureBlend;
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
			float3 rotatedValue14 = RotateAroundAxis( float3( 0,0,0 ), ase_worldPos, float3( 1,0,0 ), 90.0 );
			float simplePerlin3D12 = snoise( rotatedValue14*_NoiseScaleDust );
			simplePerlin3D12 = simplePerlin3D12*0.5 + 0.5;
			float3 ase_worldNormal = i.worldNormal;
			float dotResult58 = dot( _DustDirectionNormal , ase_worldNormal );
			float temp_output_30_0 = ( (_NoiseMin + (simplePerlin3D12 - 0.0) * (_NoiseMax - _NoiseMin) / (1.0 - 0.0)) * pow( ( ( ( dotResult58 + 1.0 ) / 2.0 ) * _DustCoverage ) , _NoiseContrast ) );
			float DirectionalDust16 = temp_output_30_0;
			float2 uv_Texture = i.uv_texcoord * _Texture_ST.xy + _Texture_ST.zw;
			float4 lerpResult6 = lerp( _BaseColor , tex2D( _Texture, uv_Texture ) , _ColorVsTextureBlend);
			float4 BaseColorTexture7 = lerpResult6;
			float layeredBlendVar10 = DirectionalDust16;
			float4 layeredBlend10 = ( lerp( BaseColorTexture7,_DustColor , layeredBlendVar10 ) );
			o.Albedo = layeredBlend10.rgb;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV111 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode111 = ( _FresnelProps.x + _FresnelProps.y * pow( 1.0 - fresnelNdotV111, _FresnelProps.z ) );
			o.Metallic = saturate( ( ( -DirectionalDust16 + _BaseCarMetallic ) - fresnelNode111 ) );
			o.Smoothness = saturate( ( ( -DirectionalDust16 + _BaseCarSmoothess ) - fresnelNode111 ) );
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

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
30;525;1381;634;1828.653;158.6542;1.925805;True;False
Node;AmplifyShaderEditor.CommentaryNode;15;-2793.711,330.7259;Inherit;False;1888.326;813.4345;Dust;19;16;42;30;27;24;23;12;21;28;11;14;58;69;99;121;122;125;127;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;23;-2766.542,881.0024;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;24;-2765.051,727.82;Inherit;False;Property;_DustDirectionNormal;DustDirectionNormal;9;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;58;-2446.806,817.8079;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;99;-2755.835,455.2053;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-2208.366,826.2974;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;122;-2076.554,826.2974;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;14;-2521.684,380.7259;Inherit;False;False;4;0;FLOAT3;1,0,0;False;1;FLOAT;90;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-2500.027,554.8046;Inherit;False;Property;_NoiseScaleDust;NoiseScale (Dust);5;0;Create;True;0;0;0;False;0;False;86.644;105.682;0;300;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2239.091,1031.277;Inherit;False;Property;_DustCoverage;DustCoverage;4;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-1878.881,790.8062;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2120.334,701.7631;Inherit;False;Property;_NoiseMax;Noise Max;8;0;Create;True;0;0;0;False;0;False;1;0.9351386;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1909.488,1029.84;Inherit;False;Property;_NoiseContrast;Noise Contrast;6;0;Create;True;0;0;0;False;0;False;5.5715;3.406296;0.01;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-2122.725,620.9895;Inherit;False;Property;_NoiseMin;Noise Min;7;0;Create;True;0;0;0;False;0;False;0.9058824;0.7623329;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;12;-2103.97,386.8976;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;27;-1771.766,481.61;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;127;-1588.869,848.5867;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1384.614,459.4376;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;2;-2789.984,-293.9893;Inherit;False;1097.975;569.2236;Base Car color or texture;5;7;6;5;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1135.654,454.9489;Inherit;True;DirectionalDust;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;116;-642.279,818.1865;Inherit;False;Property;_FresnelProps;Fresnel Props;12;0;Create;True;0;0;0;False;0;False;0,0,0;0,0.29,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;17;-1115.767,30.84596;Inherit;True;16;DirectionalDust;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2738.133,156.2517;Inherit;False;Property;_ColorVsTextureBlend;ColorVsTextureBlend;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-2737.923,-52.23531;Inherit;True;Property;_Texture;Texture;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;3;-2698.797,-232.8095;Inherit;False;Property;_BaseColor;Base Color;0;0;Create;True;0;0;0;False;0;False;0.509434,0.509434,0.509434,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;37;-834.768,345.8801;Inherit;False;Property;_BaseCarMetallic; Base Car Metallic;10;0;Create;True;0;0;0;False;0;False;0;0;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;103;-780.366,57.47195;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;6;-2316.148,-109.3718;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;111;-394.7679,786.7434;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.23;False;3;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-847.4882,525.337;Inherit;False;Property;_BaseCarSmoothess;Base Car Smoothess;11;0;Create;True;0;0;0;False;0;False;-1;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-419.657,52.30577;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-1965.339,-68.8863;Inherit;True;BaseColorTexture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchNode;115;-124.7785,659.9184;Inherit;False;0;2;8;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-436.0721,382.0741;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;113;-125.897,-4.420502;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;8;-1081.282,-325.4617;Inherit;False;7;BaseColorTexture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;9;-1076.583,-228.819;Inherit;False;Property;_DustColor;Dust Color;3;0;Create;True;0;0;0;False;0;False;1,0.8705882,0.6666667,0;1,0.8705882,0.6666667,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;114;-1.482418,299.6572;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LayeredBlendNode;10;-519.4609,-257.2573;Inherit;True;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FractNode;134;-1120.352,790.0411;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;198.6325,-7.64698;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;108;241.3902,243.4671;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;458.326,-118.0382;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/DigitalDust;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;58;0;24;0
WireConnection;58;1;23;0
WireConnection;121;0;58;0
WireConnection;122;0;121;0
WireConnection;14;3;99;0
WireConnection;125;0;122;0
WireConnection;125;1;69;0
WireConnection;12;0;14;0
WireConnection;12;1;11;0
WireConnection;27;0;12;0
WireConnection;27;3;21;0
WireConnection;27;4;28;0
WireConnection;127;0;125;0
WireConnection;127;1;42;0
WireConnection;30;0;27;0
WireConnection;30;1;127;0
WireConnection;16;0;30;0
WireConnection;103;0;17;0
WireConnection;6;0;3;0
WireConnection;6;1;4;0
WireConnection;6;2;5;0
WireConnection;111;1;116;1
WireConnection;111;2;116;2
WireConnection;111;3;116;3
WireConnection;95;0;103;0
WireConnection;95;1;37;0
WireConnection;7;0;6;0
WireConnection;115;0;111;0
WireConnection;96;0;103;0
WireConnection;96;1;38;0
WireConnection;113;0;95;0
WireConnection;113;1;115;0
WireConnection;114;0;96;0
WireConnection;114;1;115;0
WireConnection;10;0;17;0
WireConnection;10;1;8;0
WireConnection;10;2;9;0
WireConnection;134;0;30;0
WireConnection;107;0;113;0
WireConnection;108;0;114;0
WireConnection;0;0;10;0
WireConnection;0;3;107;0
WireConnection;0;4;108;0
ASEEND*/
//CHKSM=3663C74BF7BF77FACAEC89C42E67AF6151F7C5DC