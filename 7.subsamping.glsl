#define PI 3.141592653
vec2 fixuv(vec2 c)
{
    return 3.*(c-.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.;
}
vec3 Grid(vec2 uv)
{
    vec3 color=vec3(0.4);
    vec2 grid=floor(mod(uv,2.));
    if(grid.x==grid.y) color=vec3(0.6);
    color=mix(color,vec3(0.0),smoothstep(1.1*fwidth(uv.x),fwidth(uv.x),abs(uv.x)));
    color=mix(color,vec3(0.0),smoothstep(1.1*fwidth(uv.y),fwidth(uv.y),abs(uv.y)));
    return color;
}


float drawsegment(in vec2 uv,in vec2 start,in vec2 end,in float width)
{
    float f=0.;
    vec2 a=start,b=end,p=uv;
    vec2 ap=p-a;
    vec2 ab=b-a;
    float proj=clamp(dot(ap,ab)/dot(ab,ab),0.0,1.0);
    float d=length(proj*ab-ap);
    f=smoothstep(width,0.99*width,d);

    return f;
    

}

float func(in float x)
{  
    //  float T=4.0+2.0*sin(iTime);
    float T=4.0;
    return sin(2.0*PI/T*x);
}

float drawfunc(in vec2 uv)
{
    float f=0.0;
    for(float x=0.;x<=iResolution.x;x+=1.0)
    {
        float fx=fixuv(vec2(x,0.0)).x;
        float fxe=fixuv(vec2(x+1.0,0.0)).x;
        f+=drawsegment(uv,vec2(fx,func(fx)),vec2(fxe,func(fxe)),fwidth(uv.x));
    }
    return clamp(f,0.0,1.0);
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fixuv(fragCoord);
    vec3 col=Grid(uv);
    vec3 color=mix(col,vec3(1.0,1.0,0.0),drawfunc(uv));
    float c=length(uv);
     c=1.0-smoothstep(0.99,1.0,c);
    fragColor=vec4(color,1.);
}