void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	// vec2 uv=(fragCoord/min(iResolution.x,iResolution.y)-0.5)*2.0;
	vec2 uv=(2.0*fragCoord-iResolution.xy)/min(iResolution.x,iResolution.y);
	float c=length(uv);
	fragColor=vec4(vec2(c),0.0,1.0);
}


