#define PI 3.141592653
#define TMIN.1
#define TMAX 100.
#define RAYMARCH_STEP 128
#define PRECISION.001
#define AA 3
// 相机视点位
#define TIME iTime*.5
#define CAMERA_POS mat3(cos(TIME),0,-sin(TIME),0,1,0,sin(TIME),0,cos(TIME))*vec3(5,2,0)
// 相机目标点
#define CAMERA_TARGET vec3(0,0,0)
// 上方向
#define CAMERA_UP vec3(0,1,0)
// 长方体的中心位置
#define RECT_POS vec3(0,1,0)
// 长方体的尺寸
#define RECT_SIZE vec3(.5,1,1)
// 长方体的漫反射系数
#define RECT_KD vec3(1,1,0)
// 球体的球心位置
#define SPHERE_POS vec3(1.5,1,0)
// 球体的半径
#define SPHERE_R 1.
// 球体的漫反射系数
#define SPHERE_KD vec3(0,.6,.9)
#define LIGHT_POS vec3(2.,3.,0.)
// 要渲染的对象集合
float SDFArray[3];
//标记最近的物体
int minObj=0;
// 光线推进数据的结构体
struct RayMarchData{
    vec3 pos;
    bool crash;
};
vec2 fixuv(vec2 c)
{
    return 1.*(c-.5*iResolution.xy)/min(iResolution.x,iResolution.y)*2.;
}

//球体的SDF模型
float sdfSphere(vec3 p){
    return length(p-SPHERE_POS)-SPHERE_R;
}
float sdfPlane(in vec3 p)
{
    return p.y;
}
// 长方体的的SDF模型
float sdfRect(in vec3 p){
    vec3 d=abs(p-RECT_POS)-RECT_SIZE;
    return length(max(d,0.))+min(max(d.x,max(d.y,d.z)),0.);
}
// float map(in vec3 p)
// {
    //     float d=sdfSphere(p);
    //     d=min(d,sdfPlane(p+vec3(0.,1.,0.)));
    //     return d;
// }
// 所有的SDF模型
float SDFAll(vec3 ray){
    SDFArray[0]=sdfPlane(ray);
    SDFArray[1]=sdfSphere(ray);
    SDFArray[2]=sdfRect(ray);
    
    float min=SDFArray[0];
    minObj=0;
    for(int i=1;i<3;i++){
        if(min>SDFArray[i]){
            min=SDFArray[i];
            minObj=i;
        }
    }
    return min;
}
RayMarchData raymarch(in vec3 ro,in vec3 rd)
{
    float t=TMIN;
    RayMarchData rm;
    rm=RayMarchData(ro,false);
    for(int i=0;i<RAYMARCH_STEP&&t<TMAX;i++)
    {
        vec3 ray=ro+t*rd;
        float d=SDFAll(ray);
        if(d<PRECISION)
        {
            rm=RayMarchData(ray,true);
            break;
        }
        t+=d;
    }
    return rm;
}

vec3 calcNormal(in vec3 p)
{
    const float h=.0001;
    const vec2 k=vec2(1,-1);
    //     return normalize( k.xyy*sdfSphere( p + k.xyy*h ) +
    //                       k.yyx*sdfSphere( p + k.yyx*h ) +
    //                       k.yxy*sdfSphere( p + k.yxy*h ) +
    //                       k.xxx*sdfSphere( p + k.xxx*h ) );
    return normalize(k.xyy*SDFAll(p+k.xyy*h)+
    k.yyx*SDFAll(p+k.yyx*h)+
    k.yxy*SDFAll(p+k.yxy*h)+
    k.xxx*SDFAll(p+k.xxx*h));
    
}
mat3 RotateMatrix()
{
    //forward
    vec3 c=normalize(CAMERA_TARGET-CAMERA_POS);
    vec3 up=vec3(CAMERA_UP);
    //right
    vec3 r=cross(c,up);
    
    vec3 on=cross(r,c);
    return mat3(r,on,c);
    
}
// mat3 setCamera(vec3 ta,vec3 ro,float cr)
// {
    //     vec3 z=normalize(ta-ro);
    //     vec3 cp=vec3(sin(cr),cos(cr),0.0);
    //     vec3 x=normalize(cross(z,cp));
    //     vec3 y=cross(x,z);
    //     return mat3(x,y,z);
// }
float softshadow(in vec3 r,in vec3 rd,float k)
{
    float res=1.;
    float t=TMIN;
    for(int i=0;i<256&&t<TMAX;i++)
    {
        float h=SDFAll(r+rd*t);
        if(h<.001)
        return 0.;
        res=min(res,k*h/t);
        t+=h;
    }
    return res;
}
vec3 addlight(vec3 p,vec3 kd)
{
    vec3 n=calcNormal(p);
    p+=PRECISION*n;
    vec3 light=LIGHT_POS;
    vec3 lightdir=normalize(light-p);
    //求光照到着色点的向量，计算系数
    vec3 diffuse=kd*max(dot(lightdir,n),0.);
    // float diff=clamp(dot(normalize(light-p),n),0.,1.);
    float st=softshadow(p,normalize(light-p),10.);
    diffuse*=st;
    //后面部分给背光处也增加
    vec3 amb=kd * (0.4 + max(dot(-lightdir, n), 0.) * 0.3);
    return amb+diffuse;
}
vec3 render(vec2 uv)
{
    vec3 color=vec3(0.);
    // vec3 ro =vec3(4.*cos(iTime),1.0,4.*sin(iTime));
    vec3 ro=CAMERA_POS;
    // if(iMouse.z>0.01)
    // {
        //     float theta=iMouse.x/iResolution.x*2.0*PI;
        //     ro=CAMERA_POS;
        //     ro=vec3(ro.x+4.0*sin(theta),ro.y,ro.z+4.0*cos(theta));
    // }
    mat3 cam=RotateMatrix();
    //rd相机向每个像素发射的射线法向
    // vec3 rd=normalize(vec3(uv,0.0)-ro);
    vec3 rd=normalize(cam*vec3(uv,1.));
    RayMarchData rm=raymarch(ro,rd);
    if(rm.crash)
    {
        vec3 p=rm.pos;
        // 漫反射系数
        vec3 kd=vec3(0);
        if(minObj==0){
            kd=vec3(0.23);
            vec2 grid=floor(p.xz);
            kd=vec3(0.1)+mod(grid.x+grid.y,2.);
            //将px、py变换至相机世界
            // vec3 rdx = normalize(rotateMatrix * vec3(px, SCREEN_Z));
            // vec3 rdy = normalize(rotateMatrix * vec3(py, SCREEN_Z));
            // // 将栅格图像上一个像素的偏移向量转换为棋盘格水平空间内的向量
            // vec3 ddx = rd / rd.y - rdx / rdx.y;
            // vec3 ddy = rd / rd.y - rdy / rdy.y;
            // float check = CheckersGrad(pos.xz, ddx.xz, ddy.xz);
            // kd = vec3(check * 0.8 + 0.2);
        }else if(minObj==1){
            kd=SPHERE_KD;
        }else if(minObj==2){
            kd=RECT_KD;
        }
        
        // 打光
        color=addlight(p,kd);
        
    }
    return color;
}
vec3 Raymarch_AA(vec2 fragcoord)
{
    vec3 color=vec3(0.);
    float aa2=float(AA/2);
    for(int m=0;m<AA;m++)
    {
        for(int n=0;n<AA;n++)
        {
            vec2 offset=(vec2(float(m),float(n))/float(AA)-aa2);
            vec2 uv=fixuv(fragcoord+offset);
            color+=render(uv);
        }
    }
    return color/float(AA*AA);
}
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    
    vec3 color=Raymarch_AA(fragCoord);
    fragColor=vec4(color,1.);
    
}