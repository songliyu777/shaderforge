// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:True,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:0,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33882,y:32481,varname:node_9361,prsc:2|custl-7368-OUT;n:type:ShaderForge.SFN_Fresnel,id:2922,x:33006,y:32599,varname:node_2922,prsc:2;n:type:ShaderForge.SFN_Power,id:1700,x:33325,y:32643,varname:node_1700,prsc:2|VAL-2922-OUT,EXP-7527-OUT;n:type:ShaderForge.SFN_Exp,id:7527,x:33148,y:32763,varname:node_7527,prsc:2,et:0|IN-3719-OUT;n:type:ShaderForge.SFN_Slider,id:3719,x:32748,y:32873,ptovrint:False,ptlb:Range,ptin:_Range,varname:node_3719,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.5555556,max:1;n:type:ShaderForge.SFN_Add,id:8871,x:33473,y:32723,varname:node_8871,prsc:2|A-1700-OUT,B-3904-OUT;n:type:ShaderForge.SFN_DepthBlend,id:3216,x:33130,y:33015,varname:node_3216,prsc:2|DIST-3719-OUT;n:type:ShaderForge.SFN_OneMinus,id:3904,x:33372,y:32949,varname:node_3904,prsc:2|IN-3216-OUT;n:type:ShaderForge.SFN_Multiply,id:7368,x:33724,y:32552,varname:node_7368,prsc:2|A-8871-OUT,B-2430-RGB;n:type:ShaderForge.SFN_Color,id:2430,x:33591,y:32867,ptovrint:False,ptlb:Color,ptin:_Color,varname:node_2430,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0.9448277,c2:1,c3:0,c4:1;proporder:3719-2430;pass:END;sub:END;*/

Shader "Shader Forge/CustomLighting2" {
    Properties {
        _Range ("Range", Range(0, 1)) = 0.5555556
        _Color ("Color", Color) = (0.9448277,1,0,1)
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _CameraDepthTexture;
            uniform float _Range;
            uniform float4 _Color;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float4 projPos : TEXCOORD2;
                UNITY_FOG_COORDS(3)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float sceneZ = max(0,LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))) - _ProjectionParams.g);
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
////// Lighting:
                float3 finalColor = ((pow((1.0-max(0,dot(normalDirection, viewDirection))),exp(_Range))+(1.0 - saturate((sceneZ-partZ)/_Range)))*_Color.rgb);
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
