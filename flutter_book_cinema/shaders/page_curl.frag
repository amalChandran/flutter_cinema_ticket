#include<flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float pointer;
uniform vec4 container;
uniform float cornerRadius;
uniform float scrollDirection;
uniform sampler2D image;

const float r=.25;// 25% of the container width
const float scaleFactor=.2;

#define PI 3.14159265359
#define TRANSPARENT vec4(0.,0.,0.,0.)
#define RED vec4(1.,0.,0.,1.)

mat3 translate(vec2 p){
    return mat3(1.,0.,0.,0.,1.,0.,p.x,p.y,1.);
}

mat3 scale(vec2 s,vec2 p){
    return translate(p)*mat3(s.x,0.,0.,0.,s.y,0.,0.,0.,1.)*translate(-p);
}

mat3 inverse(mat3 m){
    float a00=m[0][0],a01=m[0][1],a02=m[0][2];
    float a10=m[1][0],a11=m[1][1],a12=m[1][2];
    float a20=m[2][0],a21=m[2][1],a22=m[2][2];
    
    float b01=a22*a11-a12*a21;
    float b11=-a22*a10+a12*a20;
    float b21=a21*a10-a11*a20;
    
    float det=a00*b01+a01*b11+a02*b21;
    
    return mat3(b01,(-a22*a01+a02*a21),(a12*a01-a02*a11),
    b11,(a22*a00-a02*a20),(-a12*a00+a02*a10),
    b21,(-a21*a00+a01*a20),(a11*a00-a01*a10))/det;
}

vec2 project(vec2 p,mat3 m){
    return(inverse(m)*vec3(p,1.)).xy;
}

bool inRect(vec2 p,vec4 rct){
    bool inRct=p.x>rct.x&&p.x<rct.z&&p.y>rct.y&&p.y<rct.w;
    if(!inRct){
        return false;
    }
    if(p.x<rct.x+cornerRadius&&p.y<rct.y+cornerRadius){
        return length(p-vec2(rct.x+cornerRadius,rct.y+cornerRadius))<cornerRadius;
    }
    if(p.x>rct.z-cornerRadius&&p.y<rct.y+cornerRadius){
        return length(p-vec2(rct.z-cornerRadius,rct.y+cornerRadius))<cornerRadius;
    }
    if(p.x<rct.x+cornerRadius&&p.y>rct.w-cornerRadius){
        return length(p-vec2(rct.x+cornerRadius,rct.w-cornerRadius))<cornerRadius;
    }
    if(p.x>rct.z-cornerRadius&&p.y>rct.w-cornerRadius){
        return length(p-vec2(rct.z-cornerRadius,rct.w-cornerRadius))<cornerRadius;
    }
    return true;
}

out vec4 fragColor;

void main(){
    vec2 uv=FlutterFragCoord().xy/resolution;
    vec2 center=vec2(.5,.5);
    
    float containerWidth=container.z-container.x;
    float containerLeft=container.x/resolution.x;
    float containerRight=container.z/resolution.x;
    
    float normalizedPointer=pointer*abs(scrollDirection);
    float x=(scrollDirection>0.)?containerLeft+normalizedPointer:containerRight+normalizedPointer;
    float d=(scrollDirection>0.)?x-uv.x:uv.x-x;
    
    float normalizedRadius=r*containerWidth/resolution.x;
    
    if(d>normalizedRadius){
        // Outside curl area
        fragColor=TRANSPARENT;
        
        // if(inRect(uv*resolution,container)){
            //     fragColor.a=mix(.5,0.,(d-normalizedRadius)/normalizedRadius);
        // } // this works well in a black background
    }else if(d>0.){
        // Curl area
        float theta=asin(d/normalizedRadius);
        float d1=theta*normalizedRadius;
        float d2=(PI-theta)*normalizedRadius;
        const float HALF_PI=PI/2.;
        
        vec2 s=vec2(1.+(1.-sin(HALF_PI+theta))*.1);
        mat3 transform=scale(s,center);
        vec2 curledUV=project(uv,transform);
        vec2 p1=(scrollDirection>0.)?vec2(x-d1,curledUV.y):vec2(x+d1,curledUV.y);
        
        s=vec2(1.1+sin(HALF_PI+theta)*.1);
        transform=scale(s,center);
        curledUV=project(uv,transform);
        vec2 p2=(scrollDirection>0.)?vec2(x-d2,curledUV.y):vec2(x+d2,curledUV.y);
        
        if(inRect(p2*resolution,container)){
            fragColor=texture(image,p2);
        }else if(inRect(p1*resolution,container)){
            fragColor=texture(image,p1);
            fragColor.rgb*=pow(clamp((normalizedRadius-d)/r,0.,1.),.2);
        }else if(inRect(uv*resolution,container)){
            // fragColor=vec4(0.,0.,0.,.5);
            fragColor=TRANSPARENT;// to cover up Outside curl area shade.
        }
    }else{
        // Inside curl area
        vec2 s=vec2(1.2);
        mat3 transform=scale(s,center);
        vec2 curledUV=project(uv,transform);
        
        vec2 p=(scrollDirection>0.)?vec2(x-abs(d)-PI*normalizedRadius,curledUV.y):vec2(x+abs(d)+PI*normalizedRadius,curledUV.y);
        if(inRect(p*resolution,container)){
            fragColor=texture(image,p);
        }else{
            fragColor=texture(image,uv);
        }
    }
}