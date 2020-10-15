#define M_PI 3.1415926535897932384626433832795

void main()
{
    float y = gl_FragCoord.y / iResolution.y;
    float t = u_time * 10.0;
    float tr = 0.5 + 0.5 * sin(t * 0.5 + y * M_PI * 6.0 + 0.3 * M_PI);
    float tg = 0.5 - 0.5 * sin(t * 1.0 + y * M_PI * 6.0 + 0.6 * M_PI * 25.0);
    float tb = 0.5 + 0.5 * sin(t * 1.8 + y * M_PI * 6.0 + 1.8 * M_PI * 105.0);
    gl_FragColor = vec4(tr, tg, tb, 1.0);
}
