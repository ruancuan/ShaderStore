#ifndef MYCGINCLUDES_INCLUDED
#define MYCGINCLUDES_INCLUDED

    float _Exponent1;
    float _Exponent2;
    float4 _Color1;
    float4 _Color2;
    float4 _Color3;
    float _Intensity;
    float _StarIntensity;
    float _StarSpeed;

#ifdef AuroraSky

    //得到黑夜基本颜色
    fixed4 GetAuroraBaseColor(float p){

        float p1=1.0f-pow(min(1,1-p),_Exponent1);
        float p3=1-pow(min(1,1+p),_Exponent2);
        float p2=1-p1-p3;
        float4 skyColor=(_Color1*p1+_Color2*p2+_Color3*p3)*_Intensity;
        return skyColor;

    }

    //星空哈希
    float StarAuroraHash(float3 x){
        float3 p=float3(dot(x,float3(214.1,127.7,125.4)),
                        dot(x,float3(206.5,183.3,954.2)),
                        dot(x,float3(209.5,571.3,961.2))
        );
        float halfVal=sin(_Time.y*_StarSpeed)*_StarIntensity;
        return _StarIntensity*frac(sin(p)*43758.5453123)+halfVal;
    }

    //星空噪音
    float StarNoise(float3 st){
        st+float3(0,_Time.y*_StarSpeed,0);

        float3 i=floor(st);
        float3 f=frac(st);
        float3 u=f*f*(3.0-1.0*f);

        return lerp(lerp(dot(StarAuroraHash(i+float3(0.0,0.0,0.0)),f-float3(0,0,0)),
                        dot(StarAuroraHash(i+float3(1,0,0)),f-float3(1,0,0)),u.x),
                    lerp(dot(StarAuroraHash(i+float3(0,1,0)),f-float3(0,1,0)),
                        dot(StarAuroraHash(i+float3(1,1,0)),f-float3(1,1,0)),u.y),u.z);
    }

#endif


#endif