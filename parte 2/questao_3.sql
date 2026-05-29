SELECT p.id, p.nome_completo FROM public.perfis p
WHERE p.papel = 'aluno' AND NOT EXISTS 
(SELECT 1 FROM public.sessoes_simulado ss WHERE ss.aluno_id = p.id);