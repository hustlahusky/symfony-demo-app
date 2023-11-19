<?php

declare(strict_types=1);

return (new PhpCsFixer\Config())
    ->setCacheFile(__DIR__ . '/build/.php-cs-fixer.cache')
    ->setRules([
        // Rule sets
        '@PHP82Migration' => true,
        '@PHP80Migration:risky' => true,
        '@PhpCsFixer' => true,
        '@PhpCsFixer:risky' => true,

        // Overridden rules
        'blank_line_before_statement' => [
            'statements' => [
                'break',
                'case',
                'continue',
                'declare',
                'default',
                'exit',
                'goto',
                'phpdoc',
                'return',
                'switch',
                'throw',
                'try',
            ],
        ],
        'cast_spaces' => ['space' => 'none'],
        'class_definition' => ['inline_constructor_arguments' => false, 'space_before_parenthesis' => true],
        'concat_space' => ['spacing' => 'one'],
        'empty_loop_body' => ['style' => 'braces'],
        'native_constant_invocation' => ['strict' => false],
        'native_function_invocation' => ['include' => ['@internal'], 'strict' => false],
        'no_unneeded_curly_braces' => ['namespaces' => false],
        'nullable_type_declaration_for_default_null_value' => true,
        'phpdoc_align' => ['align' => 'left'],
        'phpdoc_types_order' => ['null_adjustment' => 'always_last', 'sort_algorithm' => 'none'],
        'trailing_comma_in_multiline' => ['after_heredoc' => true, 'elements' => ['arguments', 'arrays', 'match', 'parameters']],
        'yoda_style' => ['equal' => true, 'identical' => true, 'less_and_greater' => true],

        // Disabled rules
        'escape_implicit_backslashes' => false,
        'final_internal_class' => false,
        'no_extra_blank_lines' => false,
        'php_unit_strict' => false,
        'phpdoc_add_missing_param_annotation' => false,
        'phpdoc_to_comment' => false,
    ])
    ->setRiskyAllowed(true)
    ->setFinder(
        PhpCsFixer\Finder::create()
            ->in([
                __DIR__ . '/config',
                __DIR__ . '/public',
                __DIR__ . '/src',
                __DIR__ . '/tests',
            ])
            ->append([
                __DIR__ . '/bin/console',
                __FILE__,
            ]),
    )
;
