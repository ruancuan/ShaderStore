#ifndef CARTOON
#define CARTOON

    sampler2D _MainTex;
    float4 _MainTex_ST;
    sampler2D _NormalMap;
    float4 _NormalMap_ST;
    float _BumpScale;
    float _Is_NormalMapToBase;
    float4 _BaseColor;
    float _Is_LightColor_Base;

    sampler2D _1st_ShadeMap;
    float4 _1st_ShadeMap_ST;
    float _Use_BaseAs1st;
    float4 _1st_ShadeColor;
    float _Is_LightColor_1st_Shade;

    sampler2D _2nd_ShadeMap;
    float4 _2nd_ShadeMap_ST;
    float _Use_1stAs2nd;
    float4 _2nd_ShadeColor;
    float _Is_LightColor_2nd_Shade;

    float _Set_SystemShadowsToBase;
    float _Tweak_SystemShadowsLevel;
    uniform float _BaseColor_Step;
    uniform float _BaseShade_Feather;
    uniform float _ShadeColor_Step;
    uniform float _1st2nd_Shades_Feather;

    uniform float4 _HighColor;
    uniform sampler2D _HighColor_Tex; uniform float4 _HighColor_Tex_ST;
    uniform fixed _Is_LightColor_HighColor;
    uniform fixed _Is_NormalMapToHighColor;
    uniform float _HighColor_Power;
    uniform sampler2D _Set_HighColorMask; uniform float4 _Set_HighColorMask_ST;
    uniform fixed _Is_SpecularToHighColor;
    uniform fixed _Is_BlendAddToHiColor;
    uniform fixed _Is_UseTweakHighColorOnShadow;
    uniform float _TweakHighColorOnShadow;
    uniform float _Tweak_HighColorMaskLevel;
    uniform fixed _RimLight;
    uniform float4 _RimLightColor;
    uniform fixed _Is_LightColor_RimLight;
    uniform fixed _Is_NormalMapToRimLight;
    uniform float _RimLight_Power;
    uniform float _RimLight_InsideMask;
    uniform fixed _RimLight_FeatherOff;
    uniform fixed _LightDirection_MaskOn;
    uniform sampler2D _Set_RimLightMask; uniform float4 _Set_RimLightMask_ST;
    uniform float _Tweak_RimLightMaskLevel;
    uniform float _Tweak_LightDirection_MaskLevel;
    uniform fixed _Add_Antipodean_RimLight;
    uniform float4 _Ap_RimLightColor;
    uniform fixed _Is_LightColor_Ap_RimLight;
    uniform float _Ap_RimLight_Power;
    uniform fixed _Ap_RimLight_FeatherOff;

    uniform float4 _Color;
    //Emissive
    uniform sampler2D _Emissive_Tex; uniform float4 _Emissive_Tex_ST;
    uniform float4 _Emissive_Color;

    uniform float3 emissive;
    uniform float _GI_Intensity;
    uniform float _Unlit_Intensity;
    
    uniform fixed _Is_Filter_HiCutPointLightColor;
    uniform fixed _Is_Filter_LightColor;
    uniform float _StepOffset;
    uniform fixed _Is_BLD;

    uniform float _Offset_X_Axis_BLD;
    uniform float _Offset_Y_Axis_BLD;
    uniform fixed _Inverse_Z_Axis_BLD;

    
    //
    fixed3 DecodeLightProbe( fixed3 N ){
        return ShadeSH9(float4(N,1));
    }

    struct VertexInput {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float2 texcoord0 : TEXCOORD0;
    };

    struct VertexOutput {
        float4 pos : SV_POSITION;
        float2 uv0 : TEXCOORD0;
        float4 posWorld : TEXCOORD1;
        float3 normalDir : TEXCOORD2;
        float3 tangentDir : TEXCOORD3;
        float3 bitangentDir : TEXCOORD4;
        //v.2.0.7
        float mirrorFlag : TEXCOORD5;
        LIGHTING_COORDS(6,7)
        //UNITY_FOG_COORDS(8)
        //
    };

    VertexOutput vert(VertexInput v){
        VertexOutput o = (VertexOutput)0;
        o.uv0=v.texcoord0;
        o.normalDir=UnityObjectToWorldNormal(v.normal);
        o.tangentDir=normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz,0.0)).xyz);
        o.bitangentDir=normalize(cross(o.normalDir,o.tangentDir)*v.tangent.w);
        o.posWorld=mul(unity_ObjectToWorld,v.vertex);
        o.pos=UnityObjectToClipPos(v.vertex);
        float3 lightColor=_LightColor0.rgb;
        float3 crossFwd = cross(UNITY_MATRIX_V[0], UNITY_MATRIX_V[1]);
        o.mirrorFlag = dot(crossFwd, UNITY_MATRIX_V[2]) < 0 ? 1 : -1;
        UNITY_TRANSFER_FOG(o,o.pos);
        TRANSFER_VERTEX_TO_FRAGMENT(o)
        return o;
    }
    
    float4 frag(VertexOutput i, fixed facing : VFACE) : SV_TARGET {
        float4 finalRGBA=float4(1,1,1,1);
        i.normalDir=normalize(i.normalDir);
        float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
        float3 worldViewDir=UnityWorldSpaceViewDir(i.posWorld);
        float2 Set_UV0 = i.uv0;
        float3 _NormalMap_var = UnpackScaleNormal(tex2D(_NormalMap,TRANSFORM_TEX(Set_UV0, _NormalMap)), _BumpScale);
        float3 normalLocal=_NormalMap_var.rgb;
        float3 normalDir=normalize(mul(normalLocal,tangentTransform));
        float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(Set_UV0, _MainTex));

        UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld.xyz);

    #ifdef _IS_PASS_FWDBASE
        float3 defaultLightDirection = normalize(UNITY_MATRIX_V[2].xyz + UNITY_MATRIX_V[1].xyz);
        float3 defaultLightColor = saturate(max(half3(0.05,0.05,0.05)*_Unlit_Intensity,max(ShadeSH9(half4(0.0, 0.0, 0.0, 1.0)),ShadeSH9(half4(0.0, -1.0, 0.0, 1.0)).rgb)*_Unlit_Intensity));
        float3 customLightDirection = normalize(mul( unity_ObjectToWorld, float4(((float3(1.0,0.0,0.0)*_Offset_X_Axis_BLD*10)+(float3(0.0,1.0,0.0)*_Offset_Y_Axis_BLD*10)+(float3(0.0,0.0,-1.0)*lerp(-1.0,1.0,_Inverse_Z_Axis_BLD))),0)).xyz);
        float3 lightDirection = normalize(lerp(defaultLightDirection,_WorldSpaceLightPos0.xyz,any(_WorldSpaceLightPos0.xyz)));
        lightDirection = lerp(lightDirection, customLightDirection, _Is_BLD);
        float3 lightColor = lerp(max(defaultLightColor,_LightColor0.rgb),max(defaultLightColor,saturate(_LightColor0.rgb)),_Is_Filter_LightColor);
    #elif _IS_PASS_FWDDELTA        
        float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
        //v.2.0.5: 
        float3 addPassLightColor = (0.5*dot(lerp( i.normalDir, normalDir, _Is_NormalMapToBase ), lightDirection)+0.5) * _LightColor0.rgb * attenuation;
        float pureIntencity = max(0.001,(0.299*_LightColor0.r + 0.587*_LightColor0.g + 0.114*_LightColor0.b));
        float3 lightColor = max(0, lerp(addPassLightColor, lerp(0,min(addPassLightColor,addPassLightColor/pureIntencity),_WorldSpaceLightPos0.w),_Is_Filter_LightColor));
    #endif
    
////// Lighting:
        float3 halfDirection = normalize(worldViewDir+lightDirection);
        //v.2.0.5
        _Color = _BaseColor;


    #ifdef _IS_PASS_FWDBASE
        float3 Set_LightColor=lightColor.rgb;
        float3 Set_BaseColor=lerp((_BaseColor.rgb*_MainTex_var.rgb),((_BaseColor.rgb*_MainTex_var.rgb)*Set_LightColor.rgb),_Is_LightColor_Base);

        //梯度阴影颜色
        float4 _1st_ShadeMap_var=lerp(tex2D(_1st_ShadeMap,TRANSFORM_TEX(Set_UV0,_1st_ShadeMap)),_MainTex_var,_Use_BaseAs1st);
        float3 Set_1st_ShadeColor=lerp((_1st_ShadeColor.rgb*_1st_ShadeMap_var),(_1st_ShadeColor.rgb*_1st_ShadeMap_var*Set_LightColor),_Is_LightColor_1st_Shade);
        
        float4 _2nd_ShadeMap_var = lerp(tex2D(_2nd_ShadeMap,TRANSFORM_TEX(Set_UV0, _2nd_ShadeMap)),_1st_ShadeMap_var,_Use_1stAs2nd);
        float3 Set_2nd_ShadeColor = lerp( (_2nd_ShadeColor.rgb*_2nd_ShadeMap_var.rgb), ((_2nd_ShadeColor.rgb*_2nd_ShadeMap_var.rgb)*Set_LightColor), _Is_LightColor_2nd_Shade );
        float _HalfLambert_var=0.5*dot(lerp(i.normalDir,normalDir,_Is_NormalMapToBase),lightDirection)+0.5;

        //float4 _Set_2nd_ShadePosition_var = tex2D(_Set_2nd_ShadePosition,TRANSFORM_TEX(Set_UV0, _Set_2nd_ShadePosition));
        //float4 _Set_1st_ShadePosition_var = tex2D(_Set_1st_ShadePosition,TRANSFORM_TEX(Set_UV0, _Set_1st_ShadePosition));

        float _SystemShadowsLevel_var = (attenuation*0.5)+0.5+_Tweak_SystemShadowsLevel > 0.001 ? (attenuation*0.5)+0.5+_Tweak_SystemShadowsLevel : 0.0001;
        float Set_FinalShadowMask = saturate(1.0- (lerp( _HalfLambert_var, _HalfLambert_var*saturate(_SystemShadowsLevel_var), _Set_SystemShadowsToBase )-(_BaseColor_Step-_BaseShade_Feather))  / (_BaseColor_Step - (_BaseColor_Step-_BaseShade_Feather)));

        float3 Set_FinalBaseColor = lerp(Set_BaseColor,lerp(Set_1st_ShadeColor,Set_2nd_ShadeColor,saturate((1.0 - ( (_HalfLambert_var - (_ShadeColor_Step-_1st2nd_Shades_Feather))  ) / (_ShadeColor_Step - (_ShadeColor_Step-_1st2nd_Shades_Feather))))),Set_FinalShadowMask); // Final Color
        
        //高光
        float4 _Set_HighColorMask_var = tex2D(_Set_HighColorMask,TRANSFORM_TEX(Set_UV0, _Set_HighColorMask));
        float _Specular_var=0.5*dot(halfDirection,lerp(i.normalDir,normalDir,_Is_NormalMapToHighColor))+0.5;            
        float _TweakHighColorMask_var = (saturate((_Set_HighColorMask_var.g+_Tweak_HighColorMaskLevel))*lerp( (1.0 - step(_Specular_var,(1.0 - pow(_HighColor_Power,5)))), pow(_Specular_var,exp2(lerp(11,1,_HighColor_Power))), _Is_SpecularToHighColor ));
        float4 _HighColor_Tex_var = tex2D(_HighColor_Tex,TRANSFORM_TEX(Set_UV0, _HighColor_Tex));
        float3 _HighColor_var = (lerp( (_HighColor_Tex_var.rgb*_HighColor.rgb), ((_HighColor_Tex_var.rgb*_HighColor.rgb)*Set_LightColor), _Is_LightColor_HighColor )*_TweakHighColorMask_var);
        float3 Set_HighColor = (lerp( saturate((Set_FinalBaseColor-_TweakHighColorMask_var)), Set_FinalBaseColor, lerp(_Is_BlendAddToHiColor,1.0,_Is_SpecularToHighColor) )+lerp( _HighColor_var, (_HighColor_var*((1.0 - Set_FinalShadowMask)+(Set_FinalShadowMask*_TweakHighColorOnShadow))), _Is_UseTweakHighColorOnShadow ));

        //边缘光
        float4 _Set_RimLightMask_var = tex2D(_Set_RimLightMask,TRANSFORM_TEX(Set_UV0, _Set_RimLightMask));
        float3 _Is_LightColor_RimLight_var = lerp( _RimLightColor.rgb, (_RimLightColor.rgb*Set_LightColor), _Is_LightColor_RimLight );
        float _RimArea_var = (1.0 - dot(lerp( i.normalDir, normalDir, _Is_NormalMapToRimLight ),worldViewDir))*(saturate(dot(lightDirection,lerp( i.normalDir, normalDir, _Is_NormalMapToRimLight ))));
        float _RimLightPower_var = pow(_RimArea_var,exp2(lerp(3,0,_RimLight_Power)));
        float _Rimlight_InsideMask_var = saturate(lerp( (0.0 + ( (_RimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0) ) / (1.0 - _RimLight_InsideMask)), step(_RimLight_InsideMask,_RimLightPower_var), _RimLight_FeatherOff ));
        float _VertHalfLambert_var = 0.5*dot(i.normalDir,lightDirection)+0.5;        
        float _ApRimLightPower_var = pow(_RimArea_var,exp2(lerp(3,0,_Ap_RimLight_Power)));
        float3 _LightDirection_MaskOn_var = lerp( (_Is_LightColor_RimLight_var*_Rimlight_InsideMask_var), (_Is_LightColor_RimLight_var*saturate((_Rimlight_InsideMask_var-((1.0 - _VertHalfLambert_var)+_Tweak_LightDirection_MaskLevel)))), _LightDirection_MaskOn );
        float3 Set_RimLight = lerp( _LightDirection_MaskOn_var, (_LightDirection_MaskOn_var+(lerp( _Ap_RimLightColor.rgb, (_Ap_RimLightColor.rgb*Set_LightColor), _Is_LightColor_Ap_RimLight )*saturate((lerp( (0.0 + ( (_ApRimLightPower_var - _RimLight_InsideMask) * (1.0 - 0.0) ) / (1.0 - _RimLight_InsideMask)), step(_RimLight_InsideMask,_ApRimLightPower_var), _Ap_RimLight_FeatherOff )-(saturate(_VertHalfLambert_var)+_Tweak_LightDirection_MaskLevel))))), _Add_Antipodean_RimLight );
        //Composition: HighColor and RimLight as _RimLight_var
        float3 finalColor = lerp( Set_HighColor, (Set_HighColor+Set_RimLight), _RimLight );

        float3 envLightColor = DecodeLightProbe(normalDir) < float3(1,1,1) ? DecodeLightProbe(normalDir) : float3(1,1,1);
        float envLightIntensity = 0.299*envLightColor.r + 0.587*envLightColor.g + 0.114*envLightColor.b <1 ? (0.299*envLightColor.r + 0.587*envLightColor.g + 0.114*envLightColor.b) : 1;

#ifdef _EMISSIVE_SIMPLE
        float4 _Emissive_Tex_var = tex2D(_Emissive_Tex,TRANSFORM_TEX(Set_UV0, _Emissive_Tex));
        float emissiveMask = _Emissive_Tex_var.a;
        emissive = _Emissive_Tex_var.rgb * _Emissive_Color.rgb * emissiveMask;
#endif

        finalColor =  saturate(finalColor) + (envLightColor*envLightIntensity*_GI_Intensity*smoothstep(1,0,envLightIntensity/2)) + emissive;
        finalRGBA=float4(finalColor,1);
    #endif

    #ifdef _IS_PASS_FWDDELTA
        _BaseColor_Step = saturate(_BaseColor_Step + _StepOffset);
        _ShadeColor_Step = saturate(_ShadeColor_Step + _StepOffset);

        //v.2.0.5: If Added lights is directional, set 0 as _LightIntensity
        float _LightIntensity = lerp(0,(0.299*_LightColor0.r + 0.587*_LightColor0.g + 0.114*_LightColor0.b)*attenuation,_WorldSpaceLightPos0.w) ;        
        float3 Set_LightColor = lerp(lightColor,lerp(lightColor,min(lightColor,_LightColor0.rgb*attenuation*_BaseColor_Step),_WorldSpaceLightPos0.w),_Is_Filter_HiCutPointLightColor);
        float3 Set_BaseColor = lerp( (_BaseColor.rgb*_MainTex_var.rgb*_LightIntensity), ((_BaseColor.rgb*_MainTex_var.rgb)*Set_LightColor), _Is_LightColor_Base );
        //梯度阴影颜色
        float4 _1st_ShadeMap_var=lerp(tex2D(_1st_ShadeMap,TRANSFORM_TEX(Set_UV0,_1st_ShadeMap)),_MainTex_var,_Use_BaseAs1st);
        float3 Set_1st_ShadeColor=lerp((_1st_ShadeColor.rgb*_1st_ShadeMap_var*_LightIntensity),(_1st_ShadeColor.rgb*_1st_ShadeMap_var*Set_LightColor),_Is_LightColor_1st_Shade);
        
        float4 _2nd_ShadeMap_var = lerp(tex2D(_2nd_ShadeMap,TRANSFORM_TEX(Set_UV0, _2nd_ShadeMap)),_1st_ShadeMap_var,_Use_1stAs2nd);
        float3 Set_2nd_ShadeColor = lerp( (_2nd_ShadeColor.rgb*_2nd_ShadeMap_var.rgb*_LightIntensity), ((_2nd_ShadeColor.rgb*_2nd_ShadeMap_var.rgb)*Set_LightColor), _Is_LightColor_2nd_Shade );
        float _HalfLambert_var=0.5*dot(lerp(i.normalDir,normalDir,_Is_NormalMapToBase),lightDirection)+0.5;

        float _SystemShadowsLevel_var = (attenuation*0.5)+0.5+_Tweak_SystemShadowsLevel > 0.001 ? (attenuation*0.5)+0.5+_Tweak_SystemShadowsLevel : 0.0001;
        float Set_FinalShadowMask = saturate(1.0- (lerp( _HalfLambert_var, _HalfLambert_var*saturate(_SystemShadowsLevel_var), _Set_SystemShadowsToBase )-(_BaseColor_Step-_BaseShade_Feather))  / (_BaseColor_Step - (_BaseColor_Step-_BaseShade_Feather)));

        float3 Set_FinalBaseColor = lerp(Set_BaseColor,lerp(Set_1st_ShadeColor,Set_2nd_ShadeColor,saturate((1.0 - ( (_HalfLambert_var - (_ShadeColor_Step-_1st2nd_Shades_Feather))  ) / (_ShadeColor_Step - (_ShadeColor_Step-_1st2nd_Shades_Feather))))),Set_FinalShadowMask); // Final Color
        
        //高光
        float4 _Set_HighColorMask_var = tex2D(_Set_HighColorMask,TRANSFORM_TEX(Set_UV0, _Set_HighColorMask));
        float _Specular_var=0.5*dot(halfDirection,lerp(i.normalDir,normalDir,_Is_NormalMapToHighColor))+0.5;            
        float _TweakHighColorMask_var = (saturate((_Set_HighColorMask_var.g+_Tweak_HighColorMaskLevel))*lerp( (1.0 - step(_Specular_var,(1.0 - pow(_HighColor_Power,5)))), pow(_Specular_var,exp2(lerp(11,1,_HighColor_Power))), _Is_SpecularToHighColor ));
        float4 _HighColor_Tex_var = tex2D(_HighColor_Tex,TRANSFORM_TEX(Set_UV0, _HighColor_Tex));
        float3 _HighColor_var = (lerp( (_HighColor_Tex_var.rgb*_HighColor.rgb), ((_HighColor_Tex_var.rgb*_HighColor.rgb)*Set_LightColor), _Is_LightColor_HighColor )*_TweakHighColorMask_var);
        
        Set_FinalBaseColor = Set_FinalBaseColor + lerp(lerp( _HighColor_var, (_HighColor_var*((1.0 - Set_FinalShadowMask)+(Set_FinalShadowMask*_TweakHighColorOnShadow))), _Is_UseTweakHighColorOnShadow ),float3(0,0,0),_Is_Filter_HiCutPointLightColor);

        finalRGBA=float4(Set_FinalBaseColor,1);

    #endif
        //Final Composition
        return finalRGBA;
    }
#endif