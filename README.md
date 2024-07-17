# Ansible Controller

> 🎮 Your configurations can stay home

[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square&link=https://github.com/kloudkit/ansible-controller?tab=MIT-1-ov-file#MIT-1-ov-file)](https://github.com/kloudkit/ansible-controller?tab=MIT-1-ov-file#MIT-1-ov-file)

## Documentation

The image includes a default inventory *(`/etc/ansible/hosts`)* named `controller` that
runs on `localhost` without root privileges.

To use it, copy the following example playbook:

```yaml
- name: Run something
  gather_facts: false
  hosts: controller

  tasks:
    - name: Just saying hello
      ansible.builtin.debug:
        msg: Hello world! 👋
```

### Run

```sh
docker run --rm \
  -v ./playbooks:/workspace \
  ghcr.io/kloudkit/ansible-controller \
  -e FOO=bar \
  /workspace/play.yaml
```

## License

This project is licensed under the
[**MIT License**](https://github.com/kloudkit/ansible-controller?tab=MIT-1-ov-file#MIT-1-ov-file)
