vec2 fixuv(in vec2 uv)
{
    return (uv-0.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.0;
}
float sdfcircle(in vec2 p,in float r)
{
    return length(p)-r;
}
float map(in vec2 uv)
{    
float d=sdfcircle(uv,0.7);
 d=min(d,sdfcircle(uv,0.8));
 return d;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fixuv(fragCoord);
    vec3 col = vec3(0.0);
    vec3 color2=vec3(smoothstep(2.0*fwidth(uv.x),fwidth(uv.x),sdfcircle(uv,0.8)));
    col=mix(col,vec3(0.0,1.0,0.0),color2);
    vec3 color=vec3(smoothstep(2.0*fwidth(uv.x),fwidth(uv.x),sdfcircle(uv,0.7)));
    col=mix(col,vec3(1.0,0.0,0.0),color);
    fragColor = vec4(col,1.0);
}