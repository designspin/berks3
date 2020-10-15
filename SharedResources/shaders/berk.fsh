void main() {
    vec4 val = texture2D(u_texture, v_tex_coord);
    
    if(val.r == 0.0 && val.g == 0.0 && val.b == 0.0 && val.a == 1.0) {
        gl_FragColor = u_color;
    } else {
        gl_FragColor = val;
    }
}
