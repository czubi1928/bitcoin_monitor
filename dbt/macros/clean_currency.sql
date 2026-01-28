{% macro clean_currency(column_name) %}
    nullif({{ column_name }}, 'null')::float
{% endmacro %}