#define PI 3.141592653
#define TMIN 0.1
#define TMAX 100.
#define RAYMARCH_STEP 128
#define PRECISION .001
#define AA 3
vec2 fixuv(vec2 c)
{
    return 1.*(c-.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.;
}

float sdfSphere(in vec3 p)
{
    return length(p)-1.;
}
float sdfPlane( in vec3 p )
{
  // n must be normalized
  return p.y;
}
float map(in vec3 p)
{
    float d=sdfSphere(p);
    d=min(d,sdfPlane(p+vec3(0.,1.,0.)));
    return d;
}
float raymarch(in vec3 ro ,in vec3 rd)
{
    float t=TMIN;
    for(int i=0;i<RAYMARCH_STEP&&t<TMAX;i++)
    {
        vec3 ray=ro+t*rd;
        float d=map(ray);
        if(d<PRECISION)
        {
            break;
        }
        // if(t>=TMAX)
        // {
        //     break;
        // }
        t+=d;
    }
    return t;
}

vec3 calcNormal(in vec3 p)
{
    const float h=0.0001;
    const vec2 k=vec2(1,-1);
//     return normalize( k.xyy*sdfSphere( p + k.xyy*h ) + 
//                       k.yyx*sdfSphere( p + k.yyx*h ) + 
//                       k.yxy*sdfSphere( p + k.yxy*h ) + 
//                       k.xxx*sdfSphere( p + k.xxx*h ) );
    return normalize( k.xyy*map( p + k.xyy*h ) + 
                      k.yyx*map( p + k.yyx*h ) + 
                      k.yxy*map( p + k.yxy*h ) + 
                      k.xxx*map( p + k.xxx*h ) );

}
mat3 setCamera(vec3 ta,vec3 ro,float cr)
{
    vec3 z=normalize(ta-ro);
    vec3 cp=vec3(sin(cr),cos(cr),0.0);
    vec3 x=normalize(cross(z,cp));
    vec3 y=cross(x,z);
    return mat3(x,y,z);
}
float softshadow(in vec3 ro, in vec3 rd,float k)
{
    float res = 1.0;
    float t = TMIN;
    for( int i=0; i<256 && t<TMAX; i++ )
    {
        float h = map(ro + rd*t);
        if( h<0.001 )
            return 0.0;
        res = min( res, k*h/t );
        t += h;
    }
    return res;
}
vec3 render(vec2 uv)
{
    vec3 color=vec3(0.0);
    vec3 ro =vec3(4.*cos(iTime),1.0,4.*sin(iTime));
    if(iMouse.z>0.01)
    {
        float theta=iMouse.x/iResolution.x*2.0*PI;
        ro=vec3(4.0*cos(theta),1.0,4.0*sin(theta));
    }
    vec3 ta=vec3(0.0);
    mat3 cam=setCamera(ta,ro,0.);
    //rd相机向每个像素发射的射线法向
    // vec3 rd=normalize(vec3(uv,0.0)-ro);
    vec3 rd=normalize(cam*vec3(uv,1.0));
    float t=raymarch(ro,rd);
    // color=vec3(smoothstep(TMAX,TMIN,t));
    if(t<TMAX)
    {
        vec3 p=ro+t*rd;
        vec3 n=calcNormal(p);
        // vec3 light=vec3(cos(iTime),2.0,sin(iTime));
        p+=PRECISION*n;
        vec3 light=vec3(2.0,3.0,0.0);
        float diff=clamp(dot(normalize(light-p),n),0.,1.);
        // float st=raymarch(p,normalize(light-p));
        // if(st<TMAX)
        // {
        //     diff=0.;
        // }
        float st=softshadow(p,normalize(light-p),10.0);
        diff*=st;
        float amb=0.5+0.5*dot(n,vec3(0.,1.0,0.));
        color=amb*vec3(0.25,0.23,0.23)+diff*vec3(1.0);

    }
    // if(t<TMAX)
    // {
    //     color=vec3(1.0);
    // }
    return sqrt(color);
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec3 color=vec3(0.0);
    float aa2=float(AA/2);
    for(int m=0;m<AA;m++)
    {
        for(int n=0;n<AA;n++)
        {
            vec2 offset=(vec2(float(m),float(n))/float(AA)-aa2);
            vec2 uv=fixuv(fragCoord+offset);
            color+=render(uv);
        }
    }

    fragColor=vec4(color/float(AA*AA),1.0);
}