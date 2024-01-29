void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv= 3.0*(fragCoord-0.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.0;
    vec3 col=vec3(0.0);

    vec2 cell=fract(uv);
    if(cell.x<fwidth(uv.x))
    {
        col=vec3(1.0);
    }
    if(cell.y<fwidth(uv.y))
    {
        col=vec3(1.0);
    }
        if(abs(uv.y)<fwidth(uv.y))
    {
        col=vec3(1.0,0.0,0.0);
        // col.r=1.0;
    }
    if(abs(uv.x)<fwidth(uv.x))
    {
        col=vec3(0.0,1.0,0.0);
    }
    fragColor=vec4(col,1.0);
}


