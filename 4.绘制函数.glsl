#define PI 3.141592653
vec2 fixuv(vec2 c)
{
    return 3.*(c-.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.;
}
vec3 Grid(vec2 uv)
{
    vec3 col;
    // vec2 cell=fract(uv);
    vec2 cell=1.0- 2.0*abs(fract(uv)-0.5);
    if(cell.x<2.0*fwidth(uv.x))
    {
        col=vec3(1.,1.,1.);
    }
    if(cell.y<2.0*fwidth(uv.y))
    {
        col=vec3(1.,1.,1.);
    }
    if(abs(uv.y)<=fwidth(uv.y))
    {
        col=vec3(1.,0.,0.);
    }
    if(abs(uv.x)<=fwidth(uv.x))
    {
        col=vec3(0.,1.,0.);
    }
    return col;
}


float drawsegment(in vec2 uv,in vec2 start,in vec2 end,in float width)
{
    float f=0.;
    vec2 a=start,b=end,p=uv;
    vec2 ap=p-a;
    vec2 ab=b-a;
    float proj=clamp(dot(ap,ab)/dot(ab,ab),0.0,1.0);
    float d=length(proj*ab-ap);
    if(d<width)
    {
        f=1.0;
    }
    return f;

}

float func(in float x)
{   float T=4.0+2.0*sin(iTime);
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
    fragColor=vec4(color,1.);
}