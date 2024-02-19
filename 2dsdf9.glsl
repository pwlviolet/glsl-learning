#define PI 3.141592653
vec2 fixuv(vec2 c)
{
    return 1.*(c-.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.;
}

float sdfcircle(in vec2 p,float r)
{
    return length(p)-r;
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fixuv(fragCoord);
    float d=sdfcircle(uv,0.7);
    vec3 color=1.0-sign(d)*vec3(.4,.5,.6);
    color*=1.0-exp(-3.*abs(d));
    color*=0.8+0.2*sin(100.*abs(d));
    color=mix(color,vec3(1.0,1.0,0.0),0.0);
    if(iMouse.z>0.1)
    {
    vec2 m=fixuv(iMouse.xy);
    float currentDistance=abs(sdfcircle(m,.7));
    color=mix(color,vec3(1.0,1.0,0.0),smoothstep(0.01,0.0,abs(length(uv-m)-currentDistance)));
    color=mix(color,vec3(1.0,0.0,0.0),smoothstep(0.02,0.0,length(uv-m)));
    }

    fragColor=vec4(color,1.);
}