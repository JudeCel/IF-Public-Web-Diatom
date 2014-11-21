'use strict';
var util = require('util');
var path = require('path');
var exec = require('child_process').exec;

module.exports = function (grunt) {
	var env = process.env;
	env.name = env.name || 'dev';
	var envConf = require('./config/' + env.name);

	grunt.initConfig({
		// shortcut
		conf: grunt.config.get,
		env: env,

		config: {
			dev: {
				options: {
					variables: {
						deploy_dir: '.',
						deploy_commands: []
					}
				}
			},
			for_deploy: {
				options: {
					variables: {
						deploy_dir: './deploy',
						deploy_commands: envConf.deployCommands
					}
				}
			}
		},

		node_tap: {
			tests: {
				options: {
					outputType: 'failures',// tap, failures, stats
					outputTo: 'console' // console, file
				},
				files: {
					'tests': [
						'<%= conf("deploy_dir") %>/tests/**/*.js',
						'!<%= conf("deploy_dir") %>/tests/testHelpers/**/*'
					]
				}
			}
		},

		clean: {
			mf_node_modules: ['<%= conf("deploy_dir") %>/node_modules/if-*'],
			deploy_dir: ['<%= conf("deploy_dir") %>']
		},

		exec: {
			// local dev only, our CI server will handle src code updates
			git_update: {
				cmd: 'git stash && git pull --rebase && git stash pop'
			},
			// local dev only, our CI server will destroy mf modules and do an npm install
			npm_install: {
				cwd: '<%= conf("deploy_dir") %>',
				cmd: 'npm install'
			},
			npm_install_for_deploy: {
				cwd: '<%= conf("deploy_dir") %>',
				cmd: 'npm install --production'
			}
		},

		copy: {
			for_deploy: {
				files: [
					{
						expand: true,
						dest: '<%= conf("deploy_dir") %>',
						src: [
							'./**/*.js',
							'./**/*.json',
							'./web/**/*',
							'./**/*.pem',
							'!./*.sh',
							'!./Gruntfile.js',
							'!./tests/**/*',
							'!./node_modules/**/*'
						]
					}
				]
			}
		},

		'json-replace': {
			for_ci: {
				options: {
					replace: require('./config/ci')
				},
				files: [
					{
						src: './config/master.json',
						dest: '<%= conf("deploy_dir") %>/config/master.json'
					}
				]
			},
			for_deploy: {
				options: {
					replace: require('./config/' + env.name)
				},
				files: [
					{
						src: './config/master.json',
						dest: '<%= conf("deploy_dir") %>/config/master.json'
					}
				]
			}
		}
	});

	['grunt-node-tap', 'grunt-exec', 'grunt-contrib-clean', 'grunt-contrib-copy', 'grunt-json-replace',
		'grunt-config'].forEach(grunt.loadNpmTasks);

	grunt.registerTask('run_deploy_commands', '', function () {
		var cmds = grunt.config("deploy_commands");
		if(cmds.length === 0) return;

		var done = this.async();
		var deployDir = path.resolve(grunt.config.get('deploy_dir'));
		var currentCmd;

		grunt.util.async.forEachSeries(cmds, function (cmd, cb) {
			currentCmd = cmd;
			exec(currentCmd, {
				maxBuffer: 2000 * 1024,
				cwd: path.resolve(deployDir)
			}, function (err, stdout, stderr) {
				if(err) {
					grunt.log.warn("run_deploy_commands cmd: " + currentCmd + ", stderr: " + stderr.toString());
					return cb(err);
				}
				grunt.log.writeln("run_deploy_commands cmd: " + currentCmd + ", stdout: " + stdout.toString());
				cb();
			});
		}, function (err) {
			if(err)
				grunt.fail.fatal("run_deploy_commands error: " + util.inspect(err));
			done();
		});
	});

	// local dev tasks
	grunt.registerTask('test', ['config:dev', 'node_tap:tests']);
	grunt.registerTask('update', ['config:dev', 'exec:git_update', 'clean:mf_node_modules', 'exec:npm_install']);
	grunt.registerTask('npmclean', ['config:dev', 'clean:mf_node_modules', 'exec:npm_install']);
	grunt.registerTask('gitupdate', ['config:dev', 'exec:git_update']);

	grunt.registerTask('canary', ['config:dev', 'json-replace:for_ci', 'node_tap:tests']);

	grunt.registerTask('deploy', ['config:dev', 'json-replace:for_ci', 'node_tap:tests', 'config:for_deploy',
		'clean:deploy_dir', 'copy:for_deploy', 'json-replace:for_deploy', 'exec:npm_install_for_deploy',
		'run_deploy_commands']);
};
