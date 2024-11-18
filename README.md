# Ansible Controller

> 🎮 Your configurations can stay home

[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square&link=https://github.com/kloudkit/ansible-controller?tab=MIT-1-ov-file#MIT-1-ov-file)](https://github.com/kloudkit/ansible-controller?tab=MIT-1-ov-file#MIT-1-ov-file)

[![Latest](https://img.shields.io/github/v/release/kloudkit/ansible-controller?style=flat-square)](https://github.com/kloudkit/ansible-controller/releases)

The *Ansible Controller* is a lightweight, containerized solution for managing your
Ansible playbooks.
Simplify your configuration management with a pre-configured, ready-to-use Ansible
environment that runs seamlessly in Docker.

## Usage

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
  # Mount local playbooks directory
  -v ./playbooks:/workspace \
  ghcr.io/kloudkit/ansible-controller \
  # Set playbook variables
  -e FOO=bar \
  # Specify the playbook to run
  play.yaml
```

## Contribute

Want to help make this project even better?

Contribute to *Ansible Controller* by reporting [issues][] or submitting [pull requests][].

## License

This project is licensed under the
[**MIT License**](https://github.com/kloudkit/ansible-controller?tab=MIT-1-ov-file#MIT-1-ov-file)

[issues]: https://github.com/kloudkit/ansible-controller/issues/new/choose
[pull requests]: https://github.com/kloudkit/ansible-controller/compare
