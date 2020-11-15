    uniform samplerCube tCube;
    uniform sampler2D tDudv;
    uniform float time;
    uniform float opacity;
    varying vec3 vReflect;
    varying vec3 vRefract[3];
    varying float vReflectionFactor;
    varying vec2 vUv;
    uniform bool useDudv;
    uniform vec3 remixColor;
    void main() {
      vec3 tRefract0 = vRefract[0];
      vec3 tRefract1 = vRefract[1];
      vec3 tRefract2 = vRefract[2];
      if (useDudv) {
        float waveStrength = 0.053333;
        // simple distortion (ripple) via dudv map (see )
        // https://www.youtube.com/watch?v=6B7IF6GOu7s
        vec2 distortedUv = texture2D( tDudv, vec2( vUv.x, vUv.y ) ).rg * waveStrength;
        distortedUv = vUv.xy + sin(time * 0.067) * 0.5 + vec2( distortedUv.x, distortedUv.y );
        vec2 distortion = ( texture2D( tDudv, distortedUv * 0.25 ).rg * 2.0 - 1.0 ) * waveStrength;
        tRefract0.xy += distortion;
        tRefract1.xy += distortion;
        tRefract2.xy += distortion;
      }
      // vec4 reflectedColor = textureCube( tCube, vec3( vReflect.x, vReflect.y, vReflect.z ) );
      vec4 reflectedColor = textureCube( tCube, vec3( vReflect.x, vReflect.y, vReflect.z ) );
      vec4 refractedColor = vec4(1.0);
      refractedColor.r = textureCube( tCube, vec3( tRefract0.x, tRefract0.yz ) ).r;
      refractedColor.g = textureCube( tCube, vec3( tRefract1.x, tRefract1.yz ) ).g;
      refractedColor.b = textureCube( tCube, vec3( tRefract2.x, tRefract2.yz ) ).b;
      // refractedColor.r = textureCube( tCube, vec3( -tRefract0.x, tRefract0.yz ) ).r;
      // refractedColor.g = textureCube( tCube, vec3( -tRefract1.x, tRefract1.yz ) ).g;
      // refractedColor.b = textureCube( tCube, vec3( -tRefract2.x, tRefract2.yz ) ).b;
      // vec2 coord = gl_PointCoord.xy - vec2(0.5);
      // if (length(coord) > 0.5) {
      //   discard;
      // } else {
      //   gl_FragColor = mix( refractedColor, reflectedColor, clamp( vReflectionFactor, 0.0, 1.0 ) );
      // }
      gl_FragColor = mix( reflectedColor, refractedColor, clamp( vReflectionFactor, 0.0, 1.0 ) );
      gl_FragColor.rgb = remixColor.rgb * gl_FragColor.rgb;
      gl_FragColor.a = opacity;
    }