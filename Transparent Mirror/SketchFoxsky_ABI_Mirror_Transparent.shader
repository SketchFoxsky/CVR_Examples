Shader "SketchFoxsky/TransparentCVRMirror"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _ReflectionTexLeft ("_ReflectionTexLeft", 2D) = "white" {}
        _ReflectionTexRight ("_ReflectionTexRight", 2D) = "white" {}
        _Opacity ("Opacity", Range(0,1)) = 0.5
    }
    
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityInstancing.cginc"
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 refl : TEXCOORD1;
                float4 pos : SV_POSITION;
                 
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            float4 _MainTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.refl = ComputeNonStereoScreenPos(o.pos);
                
                return o;
            }
            
            sampler2D _MainTex;
            sampler2D _ReflectionTexLeft;
            sampler2D _ReflectionTexRight;
            float _Opacity;

            fixed4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 refl;
                float4 projCoord = UNITY_PROJ_COORD(i.refl);
                float2 proj2 = float2(1 - projCoord.x / projCoord.w, projCoord.y / projCoord.w);
                if (unity_StereoEyeIndex == 0) refl = tex2D(_ReflectionTexLeft, proj2);
                else refl = tex2D(_ReflectionTexRight, proj2);

                fixed4 output = tex*refl;
               
                output.a = _Opacity;
                
                return output;
            }
            ENDCG
        }
    }
}