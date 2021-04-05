Shader "CarToon/CarToonFace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Enum(OFF,0,FRONT,1,BACK,2)]
        _CullMode("Cull Mode",int)=2
        //_BaseMap("BaseMap",2D)="white"{}
        _BaseColor("BaseColor",COLOR)=(1,1,1,1)

        _1st_ShadeMap("_1st_ShadeMap",2D)="white"{}
        _1st_ShadeColor("_1st_ShadeColor",COLOR)=(1,1,1,1)
        [Toggle(_)] 
        _Use_BaseAs1st("_Use_BaseAs1st",float)=0
        [Toggle(_)]
        _Is_LightColor_1st_Shade("_Is_LightColor_1st_Shade",float)=0
        
        _2nd_ShadeMap("_2nd_ShadeMap",2D)="white"{}
        _2nd_ShadeColor("_2nd_ShadeColor",COLOR)=(1,1,1,1)
        [Toggle(_)] 
        _Use_1stAs2nd("_Use_1stAs2nd",float)=0
        [Toggle(_)]
        _Is_LightColor_2nd_Shade("_Is_LightColor_2nd_Shade",float)=0

        _HighColor ("HighColor", Color) = (0,0,0,1)
        //v.2.0.4 HighColor_Tex
        _HighColor_Tex ("HighColor_Tex", 2D) = "white" {}
        [Toggle(_)] _Is_LightColor_HighColor ("Is_LightColor_HighColor", Float ) = 1
        [Toggle(_)] _Is_NormalMapToHighColor ("Is_NormalMapToHighColor", Float ) = 0
        _HighColor_Power ("HighColor_Power", Range(0, 1)) = 0
        [Toggle(_)] _Is_SpecularToHighColor ("Is_SpecularToHighColor", Float ) = 0
        [Toggle(_)] _Is_BlendAddToHiColor ("Is_BlendAddToHiColor", Float ) = 0
        [Toggle(_)] _Is_UseTweakHighColorOnShadow ("Is_UseTweakHighColorOnShadow", Float ) = 0
        _TweakHighColorOnShadow ("TweakHighColorOnShadow", Range(0, 1)) = 0
        _Set_HighColorMask ("Set_HighColorMask", 2D) = "white" {}
        
        _Tweak_HighColorMaskLevel ("Tweak_HighColorMaskLevel", Range(-1, 1)) = 0
        [Toggle(_)] _RimLight ("RimLight", Float ) = 0
        _RimLightColor ("RimLightColor", Color) = (1,1,1,1)
        [Toggle(_)] _Is_LightColor_RimLight ("Is_LightColor_RimLight", Float ) = 1
        [Toggle(_)] _Is_NormalMapToRimLight ("Is_NormalMapToRimLight", Float ) = 0
        _RimLight_Power ("RimLight_Power", Range(0, 1)) = 0.1
        _RimLight_InsideMask ("RimLight_InsideMask", Range(0.0001, 1)) = 0.0001
        [Toggle(_)] _RimLight_FeatherOff ("RimLight_FeatherOff", Float ) = 0
        [Toggle(_)] _LightDirection_MaskOn ("LightDirection_MaskOn", Float ) = 0
        _Tweak_LightDirection_MaskLevel ("Tweak_LightDirection_MaskLevel", Range(0, 0.5)) = 0
        [Toggle(_)] _Add_Antipodean_RimLight ("Add_Antipodean_RimLight", Float ) = 0
        _Ap_RimLightColor ("Ap_RimLightColor", Color) = (1,1,1,1)
        [Toggle(_)] _Is_LightColor_Ap_RimLight ("Is_LightColor_Ap_RimLight", Float ) = 1
        _Ap_RimLight_Power ("Ap_RimLight_Power", Range(0, 1)) = 0.1
        [Toggle(_)] _Ap_RimLight_FeatherOff ("Ap_RimLight_FeatherOff", Float ) = 0
        
        _Set_RimLightMask ("Set_RimLightMask", 2D) = "white" {}
        [Toggle(_)] _LightDirection_MaskOn ("LightDirection_MaskOn", Float ) = 0
        _Tweak_RimLightMaskLevel ("Tweak_RimLightMaskLevel", Range(-1, 1)) = 0

        [Toggle(_)]
         _Set_SystemShadowsToBase ("Set_SystemShadowsToBase", Float ) = 1
        _Tweak_SystemShadowsLevel ("Tweak_SystemShadowsLevel", Range(-0.5, 0.5)) = 0
        _BaseColor_Step ("BaseColor_Step", Range(0, 1)) = 0.5
        _BaseShade_Feather ("Base/Shade_Feather", Range(0.0001, 1)) = 0.0001
        _ShadeColor_Step ("ShadeColor_Step", Range(0, 1)) = 0
        _1st2nd_Shades_Feather ("1st/2nd_Shades_Feather", Range(0.0001, 1)) = 0.0001
        [HideInInspector] _1st_ShadeColor_Step ("1st_ShadeColor_Step", Range(0, 1)) = 0.5
        [HideInInspector] _1st_ShadeColor_Feather ("1st_ShadeColor_Feather", Range(0.0001, 1)) = 0.0001
        [HideInInspector] _2nd_ShadeColor_Step ("2nd_ShadeColor_Step", Range(0, 1)) = 0
        [HideInInspector] _2nd_ShadeColor_Feather ("2nd_ShadeColor_Feather", Range(0.0001, 1)) = 0.0001
        
        _StepOffset ("Step_Offset (ForwardAdd Only)", Range(-0.5, 0.5)) = 0
        [Toggle(_)] _Is_Filter_HiCutPointLightColor ("PointLights HiCut_Filter (ForwardAdd Only)", Float ) = 1
        
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _BumpScale ("Normal Scale", Range(0, 1)) = 1
        [Toggle(_)] 
        _Is_NormalMapToBase ("Is_NormalMapToBase", Float ) = 0
        
        _Emissive_Tex ("Emissive_Tex", 2D) = "white" {}
        [HDR]_Emissive_Color ("Emissive_Color", Color) = (0,0,0,1)
        
        
        [HideInInspector] 
        _Color ("Color", Color) = (1,1,1,1)
        [Toggle(_)]
         _Is_LightColor_Base ("Is_LightColor_Base", Float ) = 1

        //Outline
        [KeywordEnum(NML,POS)] _OUTLINE("OUTLINE MODE", Float) = 0
        _Outline_Width ("Outline_Width", Float ) = 0
        _Farthest_Distance ("Farthest_Distance", Float ) = 100
        _Nearest_Distance ("Nearest_Distance", Float ) = 0.5
        _Outline_Sampler ("Outline_Sampler", 2D) = "white" {}
        _Outline_Color ("Outline_Color", Color) = (0.5,0.5,0.5,1)
        [Toggle(_)] _Is_BlendBaseColor ("Is_BlendBaseColor", Float ) = 0
        [Toggle(_)] _Is_LightColor_Outline ("Is_LightColor_Outline", Float ) = 1
        //v.2.0.4
        [Toggle(_)] _Is_OutlineTex ("Is_OutlineTex", Float ) = 0
        _OutlineTex ("OutlineTex", 2D) = "white" {}
        //Offset parameter
        _Offset_Z ("Offset_Camera_Z", Float) = 0
        [Toggle(_)] _Is_BakedNormal ("Is_BakedNormal", Float ) = 0
        _BakedNormal ("Baked Normal for Outline", 2D) = "white" {}

        //For VR Chat under No effective light objects
        _GI_Intensity ("GI_Intensity", Range(0, 1)) = 0
        _Unlit_Intensity ("Unlit_Intensity", Range(0.001, 4)) = 1

        [Toggle(_)] 
        _Is_Filter_LightColor ("VRChat : SceneLights HiCut_Filter", Float ) = 0
        //Built-in Light Direction
        [Toggle(_)] 
        _Is_BLD ("Advanced : Activate Built-in Light Direction", Float ) = 0
        _Offset_X_Axis_BLD (" Offset X-Axis (Built-in Light Direction)", Range(-1, 1)) = -0.05
        _Offset_Y_Axis_BLD (" Offset Y-Axis (Built-in Light Direction)", Range(-1, 1)) = 0.09
        [Toggle(_)] 
        _Inverse_Z_Axis_BLD (" Inverse Z-Axis (Built-in Light Direction)", Float ) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        //OutLine
        Pass{
            Name "Outline"
            Tags {
            }
            Cull Front

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vertOutline
            #pragma fragment fragOutline
            
            #pragma multi_compile _IS_OUTLINE_CLIPPING_NO 
            #pragma multi_compile _OUTLINE_NML _OUTLINE_POS
            
            #include "../CgLibs/OutLine.cginc"

            ENDCG
        }
        
        //ForwardBase
        Pass
        {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Cull[_CullMode]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma target 3.0

            #pragma multi_compile _IS_PASS_FWDBASE
            #pragma multi_compile _EMISSIVE_SIMPLE _EMISSIVE_ANIMATION

            #include "../CgLibs/CarToon.cginc"

            ENDCG
        }
        
        //Additional中去掉BasePass中的环境光、自发光、逐顶点光照和SH光照部分
        //AddPass中处理的光源可能是非最亮平行光、点光源、聚光灯，因此计算光源的
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }

            Blend One One
            Cull[_CullMode]
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            //for Unity2018.x
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma target 3.0

            //v.2.0.4
            #pragma multi_compile _IS_CLIPPING_OFF
            #pragma multi_compile _IS_PASS_FWDDELTA
            #include "../CgLibs/CarToon.cginc"

            ENDCG
        }

        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //用最快的方式，以最低的精度运行，提升片段着色器的运行速度，减少时间
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma target 3.0
            //v.2.0.4
            #pragma multi_compile _IS_CLIPPING_OFF
            #include "../CgLibs/CarToonShadowCaster.cginc"
            ENDCG
        }

    }
}
