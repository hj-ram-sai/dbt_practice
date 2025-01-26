{% macro cents_to_dollar(currency_var, unit = 'cents', digits_to_round = 2) %}
{% if unit == 'cents' %}
round(cast({{ currency_var }} as float64) / 100, {{ digits_to_round }})
{% else %}
round(cast({{ currency_var }} as float64), {{ digits_to_round }})
{% endif %}
{% endmacro %}