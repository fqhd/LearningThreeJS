'use strict';

import { set_uniform_mat4, set_uniform_vec3 } from "./shader.js";

export function init_gl_state(gl){
	gl.clearColor(0, 0, 0, 1);
	gl.enable(gl.DEPTH_TEST);
	gl.viewport(0, 0, gl.canvas.clientWidth, gl.canvas.clientHeight);
}

export function draw_scene(gl, scene){
	const {entity_shader} = scene.shaders;
	const {light, camera, bunny, plane} = scene;

	gl.useProgram(entity_shader.program);

	load_light_to_shader(gl, entity_shader, light);
	load_camera_to_shader(gl, entity_shader, camera);

	draw_entity(gl, entity_shader, bunny);
	draw_entity(gl, entity_shader, plane);
}

function load_light_to_shader(gl, shader, light){
	set_uniform_vec3(gl, shader, 'light_position', light.position);
	set_uniform_vec3(gl, shader, 'light_color', light.color);
}

function load_camera_to_shader(gl, shader, camera){
	set_uniform_mat4(gl, shader, 'proj', camera.proj);
	set_uniform_mat4(gl, shader, 'view', camera.view);
}

function draw_entity(gl, shader, entity){
	gl.activeTexture(gl.TEXTURE0);
	gl.bindTexture(gl.TEXTURE_2D, entity.texture);

	if(entity.normal_map){
		gl.activeTexture(gl.TEXTURE1);
		gl.bindTexture(gl.TEXTURE_2D, entity.normal_map);
	}

	set_uniform_mat4(gl, shader, 'model', entity.transform.matrix);
	draw_model(gl, entity.model);
}

function draw_model(gl, model){
	gl.bindVertexArray(model.vao);
	gl.drawArrays(gl.TRIANGLES, 0, model.num_vertices);
}
