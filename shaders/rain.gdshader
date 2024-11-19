shader_type canvas_item;

#define iResolution 1.0/SCREEN_PIXEL_SIZE
#define iTime TIME
#define fragColor COLOR

uniform sampler2D iChannel0;
uniform float frequency : hint_range(-10.0, 4.0, 0.1) = 2.0; // Aumentado o valor padrão
uniform float size : hint_range(0.001, 0.05, 0.001) = 0.008; // Reduzido o tamanho

vec2 rand(vec2 c){
    mat2 m = mat2(vec2(12.9898,.16180),vec2(78.233,.31415));
    return fract(sin(m * c) * vec2(43758.5453, 14142.1));
}

vec2 noise(vec2 p){
    vec2 co = floor(p);
    vec2 mu = fract(p);
    mu = 3.*mu*mu-2.*mu*mu*mu;
    vec2 a = rand((co+vec2(0.,0.)));
    vec2 b = rand((co+vec2(1.,0.)));
    vec2 c = rand((co+vec2(0.,1.)));
    vec2 d = rand((co+vec2(1.,1.)));
    return mix(mix(a, b, mu.x), mix(c, d, mu.x), mu.y);
}

void fragment()
{
    vec2 u = UV,
         v = UV * 0.05, // Reduzido para suavizar o deslocamento
         n = noise(v*100.); // Reduzido para 100 para suavizar o ruído

    fragColor = textureLod(iChannel0, u, 1.5); // Reduzido o nível de detalhe

    for (float r = 4. ; r > frequency ; r--) {
        vec2 x = iResolution.xy * r * size,
             p = 6.28 * u * x + (n - .5) * 1.5, // Reduzido o fator de deslocamento
             s = sin(p);

        vec2 v = round(u * x - 0.25) / x;
        vec4 d = vec4(noise(v*100.), noise(v)); // Reduzido para 100

        float t = (s.x+s.y) * max(0., 1. - fract(iTime * (d.b + .05) + d.g) * 1.5); // Reduzido a velocidade e intensidade

        if (d.r < (5.-r)*.06 && t > .6) { // Ajustado os limiares
            vec3 v = normalize(-vec3(cos(p), mix(.1, 1.5, t-.6))); // Reduzido o range do mix

            fragColor = texture(iChannel0, u - v.xy * .2); // Reduzido o fator de refração
        }
    }
}