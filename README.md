os-autoinst/openQA tests for openQA
===================================

Tests for openQA using openQA. Needs the corresponding [needle repository](https://github.com/os-autoinst/os-autoinst-needles-openQA)

For more details see the [openQA project](http://os-autoinst.github.io/openQA/)


## How to contribute

This project lives in https://github.com/os-autoinst/os-autoinst-distri-openQA

Feel free to add issues or send in pull requests.

If you have questions, visit us in https://matrix.to/#/#openqa:opensuse.org

## Developing tests in a browser

If you only have a browser available, you can also develop tests with
[GitHub Codespaces](https://docs.github.com/en/codespaces).

On
[os-autoinst-distri-openQA](https://github.com/os-autoinst/os-autoinst-distri-openQA).
click on the "Code" button and select "Codespaces". Just click on the plus sign
to create a new Codespace. Or use
[this link](https://codespaces.new/os-autoinst/os-autoinst-distri-openQA?quickstart=1)
as a quickstart to resume existing instances or create new ones.

See [OpenQA in a browser](https://open.qa/docs/#_openqa_in_a_browser) for
documentation on how to use it.

You can then directly modify tests in VSCode and run
```
openqa-clone-job url-to-job CASEDIR=$PWD
```

## License

This project is licensed under the MIT license.
