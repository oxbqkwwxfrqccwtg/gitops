# Administratrix GitOps

> 🛌 NOTICE: This project is taking a quick nap. If it forgot to set an alarm, check out [its origin](https://tiaracodes-admin@bitbucket.org/administratrix/gitops.git).

**End-To-End Software Development Lifecycle Automation**

- Modular
- Decentralized
- Stateless
- Hyper-Portable
- POSIX-compliant

*administratrix GitOps* brings end-to-end automation to version-controlled
software in POSIX build environments. *GitOps* automates and orchestrates the
maintenance, integration, and distribution of version controlled software
sources across diverse build environments, CI/CD services and Git SVC services.
It's the perfect solution for teams with limited resources who strive to avoid
vendor lock-in, elevate their efficiency and effortlessly provide auditing
insights.

Built on the robust foundations of Git SVC, GNU Autoconf, GNU Automake, and GNU
Make, *GitOps* communicates, checks, and establishes build environment
requirements through standardized autoconfiguration. This ensures consistency
and efficiency across different projects and repositories, making your work less
demanding.

With [ponyfill interfaces (like polyfill but with pony
pureness)](https://ponyfill.com) to `make`, `configure`, and `man`, *GitOps* has
a familiar interface for UNIX/GNU enthusiasts.

With *administratrix GitOps*, you'll be able to:

- **Do less Ops, do more Dev**: Dedicate more time to innovation and 
                                development, with a decentralized
                                hyper-portable automaton to seamlessly automate 
                                routine GitOps targets

  **Automate Pitfalls**:        Automatically handle versioning, branching,

- **Maintain Consistency**: Ensure that all projects in your domain adhere to 
                            the same standards and workflows, reducing the 
                            chances of errors.

- **Easily Scale**: Manage and maintain numerous projects simultaneously 
                    without the added complexity.

GitOps is built with respect for shellology, in order to establish 
hyper-portability on UNIX systems, thus avoiding dependencies on any specific 
runtime environment other than a POSIX-compliant(-ish) shell. Therefore, most 
Bourne, Korn, and Z shell implementations are supported. 
Microsoft Windows (NT) environments can be integrated through the 
[MSYS2 subsystem](https://www.msys2.org/), this is experimental though.

## Getting started

Install GitOps into your current working directory.

```sh
curl -L get-gitops.administratrix.ac | sh
```

Frameworks are predefined repository layouts for specific use-cases. GitOps
collection of frameworks are supposed to grow continuously overtime. Recycle
proven patterns whenever possible. You can turn any GitOps repository into a
framework, so as soon as you find yourself having to maintain similar
repositories, you can create a framework for that.

Now, let's initialize a GitOps framework for a Typescript Node.js application.

```sh
.gitops/configure --with-framework=typescript
```

An already initialized framework will be reinitialized through patching.
Patching leaves your files in place, except for the ones that replace core
functionality of the framework. Since this is all about version-control,
don't worry. GitOps requires anything that may break functionality to operate on
a clean Git working tree, hence you can revert anytime. Changes in a framework
will automatically distribute to every repository whenever their next
interaction with GitOps occurs.

GitOps CI/CD are predefined integrations for CI/CD services. Initialize an
integration for the Bitbucket Pipelines CI/CD service with a Gitflow workflow.

```sh
.gitops/configure --with-cicd=bitbucket-pipelines --with-workflow=gitflow
```

In theory, you are now done with the configuration and have an end-to-end
automation for a SDLC of a Rust application. But think about it, you haven't
given any credentials for publishing (Rust) Cargo crates. That's why the next
command, will fail under your circumstances.

```sh
.gitops/make
```

## Development

*administratrix GitOps* is extensively tested and distributed with test-reports.
To access test suites and other developmental resources, such as documentation
and a build environment, you may request a license for *GitOps SDK*

## License

*administratrix GitOps* is licensed under the GNU Affero Public License (AGPL). 
Feel free to copy, modify and distribute this program, as long as you do so 
publicly.

You may be exempt from AGPL by requesting a proprietary license.

## Contact

* [gitops@administratrix.de](mailto:gitops@administratrix.de)
* [signal.me](https://signal.me/#p/tiara.93)
