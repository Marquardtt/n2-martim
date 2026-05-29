SELECT e.nome AS escola, COUNT(m.aluno_id) AS total_alunos FROM public.escolas e
LEFT JOIN public.matriculas m ON m.escola_id = e.id
GROUP BY e.id, e.nome
ORDER BY total_alunos DESC;