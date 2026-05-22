ALTER TABLE public.perfis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.escolas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matriculas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sessoes_simulado ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.respostas ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.rls_papel_atual()
RETURNS tipo_papel_usuario
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT papel
    FROM public.perfis
    WHERE id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.rls_eh_admin_global()
RETURNS BOOLEAN
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.perfis
        WHERE id = auth.uid()
          AND papel = 'admin_global'
    );
$$;

CREATE OR REPLACE FUNCTION public.rls_escola_admin()
RETURNS UUID
LANGUAGE SQL SECURITY DEFINER STABLE AS $$
    SELECT id
    FROM public.escolas
    WHERE admin_id = auth.uid()
    LIMIT 1;
$$;

CREATE POLICY pol_aluno_selecionar_proprio_perfil
    ON public.perfis FOR SELECT
    USING (id = auth.uid());

CREATE POLICY pol_aluno_atualizar_proprio_perfil
    ON public.perfis FOR UPDATE
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

CREATE POLICY pol_admin_escola_selecionar_perfis
    ON public.perfis FOR SELECT
    USING (
        public.rls_papel_atual() = 'admin_escola'
        AND EXISTS (
            SELECT 1
            FROM public.matriculas m
            JOIN public.escolas e ON e.id = m.escola_id
            WHERE m.aluno_id = perfis.id
              AND e.admin_id = auth.uid()
        )
    );

CREATE POLICY pol_admin_global_todos_perfis
    ON public.perfis FOR ALL
    USING (public.rls_eh_admin_global())
    WITH CHECK (public.rls_eh_admin_global());

CREATE POLICY pol_admin_escola_selecionar_propria_escola
    ON public.escolas FOR SELECT
    USING (admin_id = auth.uid());

CREATE POLICY pol_admin_escola_atualizar_propria_escola
    ON public.escolas FOR UPDATE
    USING (admin_id = auth.uid())
    WITH CHECK (admin_id = auth.uid());

CREATE POLICY pol_admin_global_todas_escolas
    ON public.escolas FOR ALL
    USING (public.rls_eh_admin_global())
    WITH CHECK (public.rls_eh_admin_global());

CREATE POLICY pol_aluno_selecionar_proprias_matriculas
    ON public.matriculas FOR SELECT
    USING (aluno_id = auth.uid());

CREATE POLICY pol_admin_escola_todas_matriculas
    ON public.matriculas FOR ALL
    USING (
        EXISTS (
            SELECT 1
            FROM public.escolas e
            WHERE e.id = matriculas.escola_id
              AND e.admin_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.escolas e
            WHERE e.id = matriculas.escola_id
              AND e.admin_id = auth.uid()
        )
    );

CREATE POLICY pol_admin_global_todas_matriculas
    ON public.matriculas FOR ALL
    USING (public.rls_eh_admin_global())
    WITH CHECK (public.rls_eh_admin_global());

CREATE POLICY pol_autenticado_selecionar_questoes
    ON public.questoes FOR SELECT
    USING (auth.uid() IS NOT NULL);

CREATE POLICY pol_admin_global_escrever_questoes
    ON public.questoes FOR ALL
    USING (public.rls_eh_admin_global())
    WITH CHECK (public.rls_eh_admin_global());

CREATE POLICY pol_aluno_selecionar_proprias_sessoes
    ON public.sessoes_simulado FOR SELECT
    USING (aluno_id = auth.uid());

CREATE POLICY pol_aluno_inserir_proprias_sessoes
    ON public.sessoes_simulado FOR INSERT
    WITH CHECK (aluno_id = auth.uid());

CREATE POLICY pol_aluno_atualizar_proprias_sessoes
    ON public.sessoes_simulado FOR UPDATE
    USING (aluno_id = auth.uid())
    WITH CHECK (aluno_id = auth.uid());

CREATE POLICY pol_admin_escola_selecionar_sessoes
    ON public.sessoes_simulado FOR SELECT
    USING (
        public.rls_papel_atual() = 'admin_escola'
        AND EXISTS (
            SELECT 1
            FROM public.matriculas m
            JOIN public.escolas e ON e.id = m.escola_id
            WHERE m.aluno_id = sessoes_simulado.aluno_id
              AND e.admin_id = auth.uid()
        )
    );

CREATE POLICY pol_admin_global_todas_sessoes
    ON public.sessoes_simulado FOR ALL
    USING (public.rls_eh_admin_global())
    WITH CHECK (public.rls_eh_admin_global());

CREATE POLICY pol_aluno_selecionar_proprias_respostas
    ON public.respostas FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.sessoes_simulado ss
            WHERE ss.id = respostas.sessao_id
              AND ss.aluno_id = auth.uid()
        )
    );

CREATE POLICY pol_aluno_inserir_proprias_respostas
    ON public.respostas FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.sessoes_simulado ss
            WHERE ss.id = respostas.sessao_id
              AND ss.aluno_id = auth.uid()
        )
    );

CREATE POLICY pol_admin_escola_selecionar_respostas
    ON public.respostas FOR SELECT
    USING (
        public.rls_papel_atual() = 'admin_escola'
        AND EXISTS (
            SELECT 1
            FROM public.sessoes_simulado ss
            JOIN public.matriculas m ON m.aluno_id = ss.aluno_id
            JOIN public.escolas e ON e.id = m.escola_id
            WHERE ss.id = respostas.sessao_id
              AND e.admin_id = auth.uid()
        )
    );

CREATE POLICY pol_admin_global_todas_respostas
    ON public.respostas FOR ALL
    USING (public.rls_eh_admin_global())
    WITH CHECK (public.rls_eh_admin_global());