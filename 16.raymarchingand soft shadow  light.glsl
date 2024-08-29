#define PI 3.141592653
#define TMIN .1
#define TMAX 100.
#define RAYMARCH_STEP 128
#define PRECISION.001
#define AA 3
vec2 fixuv(vec2 c)
{
    return 1.*(c-.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.;
}

float sdfSphere(in vec3 p)
{
    return length(p)-1.;
}
float sdfPlane(in vec3 p)
{
    // n must be normalized
    return p.y;
}
vec2 opU(vec2 a,vec2 b)
{
    return a.x<b.x?a:b;
}
vec2 map(in vec3 p)
{
    vec2 d=vec2(sdfSphere(p),2.);
    d=opU(d,vec2(sdfPlane(p+vec3(0.,1.,0.)),1.));
    return d;
}
vec2 raymarch(in vec3 ro,in vec3 rd)
{
    float t=TMIN;
    vec2 res=vec2(-1.);
    for(int i=0;i<RAYMARCH_STEP&&t<TMAX;i++)
    {
        vec3 ray=ro+t*rd;
        vec2 d=map(ray);
        
        if(d.x<PRECISION)
        {
            res=vec2(t,d.y);
            break;
        }
        // if(t>=TMAX)
        // {
            //     break;
        // }
        t+=d.x;
    }
    return res;
}

vec3 calcNormal(in vec3 p)
{
    const float h=.0001;
    const vec2 k=vec2(1,-1);
    //     return normalize( k.xyy*sdfSphere( p + k.xyy*h ) +
    //                       k.yyx*sdfSphere( p + k.yyx*h ) +
    //                       k.yxy*sdfSphere( p + k.yxy*h ) +
    //                       k.xxx*sdfSphere( p + k.xxx*h ) );
    return normalize(k.xyy*map(p+k.xyy*h).x+
    k.yyx*map(p+k.yyx*h).x+
    k.yxy*map(p+k.yxy*h).x+
    k.xxx*map(p+k.xxx*h).x);
    
}
mat3 setCamera(vec3 ta,vec3 ro,float cr)
{
    vec3 z=normalize(ta-ro);
    vec3 cp=vec3(sin(cr),cos(cr),0.);
    vec3 x=normalize(cross(z,cp));
    vec3 y=cross(x,z);
    return mat3(x,y,z);
}
float softshadow(in vec3 ro,in vec3 rd,float k)
{
    float res=1.;
    float t=TMIN;
    for(int i=0;i<256&&t<TMAX;i++)
    {
        float h=map(ro+rd*t).x;
        if(h<.001)
        return 0.;
        res=min(res,k*h/t);
        t+=h;
    }
    return res;
}
vec3 render(vec2 uv)
{
    vec3 color=vec3(0.);
    vec3 ro=vec3(4.*cos(iTime),1.,4.*sin(iTime));
    if(iMouse.z>.01)
    {
        float theta=iMouse.x/iResolution.x*2.*PI;
        ro=vec3(4.*cos(theta),1.,4.*sin(theta));
    }
    vec3 ta=vec3(0.);
    mat3 cam=setCamera(ta,ro,0.);
    //rd相机向每个像素发射的射线法向
    // vec3 rd=normalize(vec3(uv,0.0)-ro);
    vec3 rd=normalize(cam*vec3(uv,1.));
    vec2 t=raymarch(ro,rd);
    // color=vec3(smoothstep(TMAX,TMIN,t));
    if(t.y>0.)
    {
        vec3 p=ro+t.x*rd;
        vec3 n=calcNormal(p);
        // vec3 light=vec3(cos(iTime),2.0,sin(iTime));
        p+=PRECISION*n;
        vec3 light=vec3(2.,3.,0.);
        float diff=clamp(dot(normalize(light-p),n),0.,1.);
        // float st=raymarch(p,normalize(light-p));
        // if(st<TMAX)
        // {
            //     diff=0.;
        // }
        float st=softshadow(p,normalize(light-p),10.);
        diff*=st;
        float amb=.5+.5*dot(n,vec3(0.,1.,0.));
        vec3 c=vec3(0.);
        if(t.y>1.9&&t.y<2.1)
        {
            c=vec3(1.0,0.0,0.0);
        }
        else if(t.y>0.9&&t.y<1.1)
        {
            c=vec3(0.23);
        }
        color=amb*c+diff*vec3(0.7);
        
    }
    // if(t<TMAX)
    // {
        //     color=vec3(1.0);
    // }
    return sqrt(color);
}
// 抗锯齿 Anti-Aliasing
vec3 RayMarch_anti(vec2 fragCoord) {
  // 初始颜色
  vec3 color = vec3(0);
  // 行列的一半
  float aa2 = float(AA / 2);
  // 逐行列遍历
  for(int y = 0; y < AA; y++) {
    for(int x = 0; x < AA; x++) {
      // 基于像素的偏移距离
      vec2 offset = vec2(float(x), float(y)) / float(AA) - aa2;
      // 坐标位
      vec2 uv=fixuv(fragCoord + offset);
      // 累加周围片元的颜色
      color += render(uv);
    }
  }
  // 返回周围颜色的均值
  return color / float(AA * AA);
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    // vec3 color=vec3(0.);
    // for(int m=0;m<AA;m++)
    // {
    //     for(int n=0;n<AA;n++)
    //     {
    //         vec2 offset=2.*(vec2(float(m),float(n)/float(AA)-.5));
    //         vec2 uv=fixuv(fragCoord+offset);
    //         color+=render(uv);
    //     }
    // }
    
    // fragColor=vec4(color/float(AA*AA),1.);
      // 光线推进
  vec3 color = RayMarch_anti(fragCoord);
  // 最终颜色
  fragColor = vec4(color, 1);
}