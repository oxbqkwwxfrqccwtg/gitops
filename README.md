# Administratrix GitOps

**End-To-End Software Development Lifecycle Automation**

- GitOps-principled
- Modular
- Decentralized
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
a familiar interface for UNIX/GNU build environments.

With *administratrix GitOps*, you'll be able to:

- **Do less Ops, do more Dev**: Dedicate more time to innovation and 
                                development, with a decentralized
                                hyper-portable automaton to seamlessly automate 
                                routine GitOps targets

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

*administratrix GitOps* is currently licensed under the GNU Affero Public 
License. Feel free to copy and modify this program, but ensure that your 
changes are made publicly available. To keep your changes private, you may
request a proprietary private license.

For access to development resources, such as documentation, test suites and
build environment, you may purchase a license for *administratrix GitOps SDK*.

**Need some information? [Let's have a chat on Signal!](https://signal.me/#p/tiara.93)**

# Getting started

This will initialize a directory as a GitOps repository for typescript and
GitLab pipelines, as well as Bitbucket pipelines:

```sh
$> mdkir my-project && cd $_
$> curl <url-to-your-gitops-distribution>/configure | sh \
    --with-git \
    --wtih-gitops \
    --with-framework=typescript \
    --with-cicd=github-actions \
    --with-autoconf \
```

To keep the sources maintainable, development tasks, such as testing, and
generating documentation are handled through a different repository 
([gitops-dev](https://bitbucket.org/victorykit/gitops-dev/src/master/)), with 
this repository as a `src/` submodule.
