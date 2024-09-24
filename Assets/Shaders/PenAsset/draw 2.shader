Shader "Custom/InvertColorShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TimeMultiplier ("Time Multiplier", Float) = 16.0
        _DistortAll ("Distort All", Float) = 0.0
        _InvertColor ("Invert Color", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _TimeMultiplier;
            float _DistortAll;
            float _InvertColor;

            float rand(float x)
            {
                return frac(sin(x) * 43758.5453);
            }

            float triang(float x)
            {
                return abs(1.0 - fmod(abs(x), 2.0)) * 2.0 - 1.0;
            }

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float time = floor(_Time.y * _TimeMultiplier) / _TimeMultiplier;

                // pixel position
                float2 p = i.uv;
                p += float2(triang(p.y * rand(time) * 4.0) * rand(time * 1.9) * 0.015, triang(p.x * rand(time * 3.4) * 4.0) * rand(time * 2.1) * 0.015);
                p += float2(rand(p.x * 3.1 + p.y * 8.7) * 0.01,
                            rand(p.x * 1.1 + p.y * 6.7) * 0.01);

                float4 baseColor;
                if (_DistortAll > 0.5)
                {
                    float2 blurredUV = float2(p.x + 0.003, p.y + 0.003);
                    baseColor = tex2D(_MainTex, blurredUV);
                }
                else
                {
                    baseColor = tex2D(_MainTex, i.uv);
                }

                float4 edges = 1.0 - (baseColor / tex2D(_MainTex, p));

                if (_InvertColor > 0.5)
                {
                    float gray = dot(baseColor.rgb, float3(0.299, 0.587, 0.114));
                    baseColor.rgb = float3(gray, gray, gray);
                    return baseColor / length(edges);
                }
                else
                {
                    return float4(length(edges), length(edges), length(edges), 1.0);
                }
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
