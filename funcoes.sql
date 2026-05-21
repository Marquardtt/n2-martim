CREATE OR REPLACE FUNCTION public.fn_definir_atualizado_em()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    NEW.atualizado_em := NOW();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_tratar_novo_usuario()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public AS $$
DECLARE
    v_papel tipo_papel_usuario;
BEGIN
    BEGIN
        v_papel := COALESCE(
            (NEW.raw_user_meta_data->>'papel')::tipo_papel_usuario,
            'aluno'
        );

    EXCEPTION WHEN invalid_text_representation THEN
        v_papel := 'aluno';
    END;

    INSERT INTO public.perfis (id, nome_completo, papel)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'nome_completo', 'Novo Usuário'),
        v_papel
    );

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_validar_papel_admin_escola()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.perfis
        WHERE id = NEW.admin_id
          AND papel = 'admin_escola'
    ) THEN
        RAISE EXCEPTION
            'admin_id % deve pertencer a um admin',
            NEW.admin_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_validar_papel_aluno()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM public.perfis
        WHERE id = NEW.aluno_id
          AND papel = 'aluno'
    ) THEN
        RAISE EXCEPTION
            'aluno_id % deve pertencer a um aluno.',
            NEW.aluno_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_atualizar_estatisticas_sessao()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE public.sessoes_simulado
    SET
        total_questoes = total_questoes + 1,
        total_acertos = total_acertos + (
            CASE
                WHEN NEW.esta_correta THEN 1
                ELSE 0
            END
        )
    WHERE id = NEW.sessao_id;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.fn_impedir_resposta_sessao_concluida()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM public.sessoes_simulado
        WHERE id = NEW.sessao_id
          AND status = 'concluida'
    ) THEN
        RAISE EXCEPTION
            'Não é permitido registrar respostas em uma sessão concluida (sessao_id: %).',
            NEW.sessao_id;
    END IF;

    RETURN NEW;
END;
$$;