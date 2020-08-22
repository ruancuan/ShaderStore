Shader "Unlit/AuroraSky"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Exponent1("Exponent1",float)=1.0
        _Exponent2("Exponent2",float)=1.0
        _Color1("Color1",COLOR)=(1,1,1,1)
        _Color2("Color2",COLOR)=(1,1,1,1)
        _Color3("Color3",COLOR)=(1,1,1,1)
        _Intensity("Intensity",float)=1.0
        _StarIntensity("StarIntensity",Range(0,1))=0.5
        _StarSpeed("StarSpeed",float)=1
        _StarColor("StarColor",COLOR)=(1,1,1,1)
        _StarThreshold("StarThreshold",float)=1
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
            // make fog work
            #pragma multi_compile_fog

            #define AuroraSky 1

            #include "UnityCG.cginc"
            #include "../CgIncludes/MyCgIncludes.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _StarColor;
            float _StarThreshold;
            float4 _StarDir;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 skyColor= GetAuroraBaseColor(i.uv.y);
                int reflection=i.uv.y>0?1:-1;
                //星星
                float star  =StarNoise(fixed3(i.uv.x,i.uv.y * reflection,i.uv.z) * 64);
                float4 starOriCol = float4(_StarColor.r + 3.25*sin(i.uv.x) + 2.45 * (sin(_Time.y * _StarSpeed) + 1)*0.5,
                                        _StarColor.g + 3.85*sin(i.uv.y) + 1.45 * (sin(_Time.y * _StarSpeed) + 1)*0.5,
                                        _StarColor.b + 3.45*sin(i.uv.z) + 4.45 * (sin(_Time.y * _StarSpeed) + 1)*0.5,
                                        (_StarColor.a + 3.85*star));
                star = star > 0.8 ? star:smoothstep(0.81,0.98,star)*sin(_Time.y*_StarSpeed);

                float4 starCol = fixed4((starOriCol * star).rgb,star);
                starCol = reflection==1?starCol:starCol*0.5;
                skyColor = skyColor*(1 - starCol.a) + _StarColor * starCol.a;
                return skyColor;
            }
            ENDCG
        }
    }
}
