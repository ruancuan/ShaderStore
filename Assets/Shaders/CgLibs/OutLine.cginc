#ifndef CARTOON_OUTLINE
#define CARTOON_OUTLINE

    uniform float _Outline_Width;
    uniform float _Farthest_Distance;
    uniform float _Nearest_Distance;
    uniform sampler2D _Outline_Sampler; uniform float4 _Outline_Sampler_ST;
    uniform float4 _Outline_Color;
    uniform fixed _Is_BlendBaseColor;
    uniform float _Offset_Z;
    uniform sampler2D _BakedNormal; uniform float4 _BakedNormal_ST;
    uniform fixed _Is_BakedNormal;

    struct VertexInput {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 texcoord0 : TEXCOORD0;
    };
    struct VertexOutput {
        float4 pos : SV_POSITION;
        float2 uv0 : TEXCOORD0;
        float3 normalDir : TEXCOORD1;
        float3 tangentDir : TEXCOORD2;
        float3 bitangentDir : TEXCOORD3;
    };

    VertexOutput vertOutline (VertexInput v) {
        VertexOutput o = (VertexOutput)0;
        o.uv0 = v.texcoord0;
        float4 worldPos=mul(unity_ObjectToWorld,v.vertex);
        float2 Set_UV0=o.uv0;
        float4 _Outline_Sampler_var=tex2Dlod(_Outline_Sampler,float4(TRANSFORM_TEX(Set_UV0, _Outline_Sampler),0.0,0));
        o.normalDir=UnityObjectToWorldNormal(v.normal);
        o.tangentDir=UnityObjectToWorldDir(v.tangent.xyz);
        o.bitangentDir=normalize(cross(o.normalDir,o.tangentDir)*v.tangent.w);
        float3x3 tangentTransform = float3x3( o.tangentDir, o.bitangentDir, o.normalDir);
        float4 _BakedNormal_var = (tex2Dlod(_BakedNormal,float4(TRANSFORM_TEX(Set_UV0, _BakedNormal),0.0,0)) * 2 - 1);
        float3 _BakedNormalDir = normalize(mul(_BakedNormal_var.rgb, tangentTransform));
        
        //ここまで.
        float Set_Outline_Width = (_Outline_Width*0.001*smoothstep( _Farthest_Distance, _Nearest_Distance, distance(worldPos.rgb,_WorldSpaceCameraPos) )*_Outline_Sampler_var.rgb).r;
        //v.2.0.7.5
        float4 _ClipCameraPos = mul(UNITY_MATRIX_VP, float4(_WorldSpaceCameraPos.xyz, 1));
        #if defined(UNITY_REVERSED_Z)
            //v.2.0.4.2 (DX)
            _Offset_Z = _Offset_Z * -0.01;
        #else
            //OpenGL
            _Offset_Z = _Offset_Z * 0.01;
        #endif

#ifdef _OUTLINE_NML
        //v.2.0.4.3 baked Normal Texture for Outline
        o.pos = UnityObjectToClipPos(lerp(float4(v.vertex.xyz + v.normal*Set_Outline_Width,1), float4(v.vertex.xyz + _BakedNormalDir*Set_Outline_Width,1),_Is_BakedNormal));
#elif _OUTLINE_POS
        Set_Outline_Width = Set_Outline_Width*2;
        float signVar = dot(normalize(v.vertex),normalize(v.normal))<0 ? -1 : 1;
        o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + signVar*normalize(v.vertex)*Set_Outline_Width, 1));
#endif
        o.pos.z = o.pos.z + _Offset_Z * _ClipCameraPos.z;
        return o;
    }


    float4 fragOutline(VertexOutput i) : SV_Target{
        //_Color = _BaseColor;
        float4 finalRGBA=float4(_Outline_Color);
        return finalRGBA;
    }

#endif