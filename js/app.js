import * as THREE from "three";

import fragment from "./shader/fragment.glsl";
import vertex from "./shader/vertex.glsl";
import dudvURL from "../tex/waterdudv.jpg";

let OrbitControls = require("three-orbit-controls")(THREE);

export default class Sketch {
  constructor(options) {
    this.scene = new THREE.Scene();

    this.container = options.dom;
    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;
    this.renderer = new THREE.WebGLRenderer();
    this.renderer.setPixelRatio(window.devicePixelRatio);
    this.renderer.setSize(this.width, this.height);
    this.renderer.setClearColor(0xeeeeee, 1);
    this.renderer.outputEncoding = THREE.sRGBEncoding;

    this.container.appendChild(this.renderer.domElement);

    this.camera = new THREE.PerspectiveCamera(
      70,
      window.innerWidth / window.innerHeight,
      0.001,
      1000
    );

    this.camera.position.set(0, 0, 2);
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.time = 0;

    this.isPlaying = true;

    this.gridSize = 1;
    this.size = 70;
    this.cellSize = this.gridSize / this.size;

    this.addObjects();
    this.resize();
    this.render();
    this.setupResize();
    // this.settings();
  }

  //   settings() {
  //     let that = this;
  //     this.settings = {
  //       progress: 0,
  //     };
  //     this.gui = new dat.GUI();
  //     this.gui.add(this.settings, "progress", 0, 1, 0.01);
  //   }

  setupResize() {
    window.addEventListener("resize", this.resize.bind(this));
  }

  resize() {
    this.width = this.container.offsetWidth;
    this.height = this.container.offsetHeight;
    this.renderer.setSize(this.width, this.height);
    this.camera.aspect = this.width / this.height;
    this.camera.updateProjectionMatrix();
  }

  addObjects() {
    let that = this;
    this.material = new THREE.ShaderMaterial({
      extensions: {
        derivatives: "#extension GL_OES_standard_derivatives : enable",
      },
      side: THREE.DoubleSide,
      transparent: true,
      uniforms: {
        remixColor: { value: new THREE.Color("#ffffff") },
        uWozzy: { value: 1 },
        mRefractionRatio: { value: 1.02 },
        mFresnelBias: { value: 0.1 },
        mFresnelPower: { value: 0.7 },
        mFresnelScale: { value: 0.6 },
        tCube: { value: null },
        time: { value: 0 },
        tDudv: { value: new THREE.TextureLoader().load(dudvURL) },
        useDudv: { value: true },
        opacity: { value: 0.8 },
      },
      vertexShader: vertex,
      fragmentShader: fragment,
    });

    this.geometry = new THREE.BoxBufferGeometry(1, 1, 1);

    this.cube = new THREE.Mesh(this.geometry, this.material);

    this.scene.add(this.cube);

    const light = new THREE.PointLight(0xff0000, 1, 100);
    light.position.set(100, 100, 100);
    this.scene.add(light);
  }

  stop() {
    this.isPlaying = false;
  }

  play() {
    if (!this.isPlaying) {
      this.render();
      this.isPlaying = true;
    }
  }

  render() {
    if (!this.isPlaying) return;
    this.time += 0.05;
    this.material.uniforms.time.value = this.time;
    requestAnimationFrame(this.render.bind(this));
    this.renderer.render(this.scene, this.camera);
  }
}

new Sketch({
  dom: document.getElementById("container"),
});
