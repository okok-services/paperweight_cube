    uniform float mRefractionRatio;
    uniform float mFresnelBias;
    uniform float mFresnelScale;
    uniform float mFresnelPower;
    uniform float uWozzy;
    uniform float time;
    varying vec3 vReflect;
    varying vec3 vRefract[3];
    varying float vReflectionFactor;
    varying vec2 vUv;

        void main() {
      vUv = uv;
      vec3 funPos = position;
      // float cx = cnoise(normal.x + vec2(position.x * 0.11) + time) * 0.1 * uWozzy;
      // float cy = cnoise(normal.y + vec2(position.y * 0.12) + time) * 0.1 * uWozzy;
      // float cz = cnoise(normal.z + vec2(position.z * 0.13) + time) * 0.1 * uWozzy;
      // funPos.x += funPos.x * cx;
      // funPos.y += funPos.y * cy;
      // funPos.z += funPos.z * cz;
      vec4 mvPosition = modelViewMatrix * vec4( funPos, 1.0 );
      vec4 worldPosition = modelMatrix * vec4( funPos, 1.0 );
      vec3 worldNormal = normalize( mat3( modelMatrix[0].xyz, modelMatrix[1].xyz, modelMatrix[2].xyz ) * normal );
      vec3 I = worldPosition.xyz - cameraPosition;
      vReflect = reflect( I, worldNormal );
      vRefract[0] = refract( normalize( I ), worldNormal, mRefractionRatio );
      vRefract[1] = refract( normalize( I ), worldNormal, mRefractionRatio * 0.99 );
      vRefract[2] = refract( normalize( I ), worldNormal, mRefractionRatio * 0.98 );
      vReflectionFactor = mFresnelBias + mFresnelScale * pow( 1.0 + dot( normalize( I ), worldNormal ), mFresnelPower );
      gl_Position = projectionMatrix * mvPosition;
      gl_PointSize = 10.0;
    }