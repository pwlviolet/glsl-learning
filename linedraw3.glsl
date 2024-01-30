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

vec2 fixuv(vec2 c)
{
    return 3.*(c-.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.;
}



vec3 drawsegment(vec2 uv,vec2 start,vec2 end,float width)
{
    vec2 a=start,b=end,p=uv;
    vec2 ap=p-a;
    vec2 ab=b-a;
    float proj=clamp(dot(ap,ab)/dot(ab,ab),0.0,1.0);
    float d=length(proj*ab-ap);
    if(d<width)
    return vec3(1.0);

}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=fixuv(fragCoord);
    vec3 col=Grid(uv);
    vec2 start=vec2(0.0);
    vec2 end=vec2(2.0,2.0);
    float width=0.01;
    vec3 line=drawsegment(uv,start,end,width);
    col=col+line;
    fragColor=vec4(col,1.);
}