DECLARE @TITULO VARCHAR(9) = '090514'

DECLARE @FORNECEDOR VARCHAR(6) = '000051'

SELECT * from AFN010
WHERE AFN_DOC = @TITULO
AND AFN_FORNEC = @FORNECEDOR
	AND D_E_L_E_T_ = ' '

SELECT *
FROM AFR010
WHERE AFR_NUM = @TITULO
	AND AFR_FORNEC = @FORNECEDOR
	AND D_E_L_E_T_ = ' '

--SELECT D1_FORNECE,
--	D1_LOJA,
--	D1_ITEM,
--	D1_COD, D1_QUANT
--FROM SD1010
--WHERE D1_DOC = @TITULO
--AND D1_FORNECE = @FORNECEDOR
--	AND D_E_L_E_T_ = ' '

--SELECT * FROM AJ7010 WHERE AJ7_NUMPC = '002013402' AND D_E_L_E_T_ = ' '
--SELECT * FROM AF8010 WHERE AF8_PROJET = 'O33015'

SELECT E2_NUM,
	E2_VALOR,
	E2_FORNECE,
	E2_TIPO,
	E2_NOMFOR
	E2_CCD,
	F1_DOC,
	D1_DOC,
	D1_QUANT,
	D1_VUNIT,
	D1_VALBRUT,
	AFR_PROJET,
	AFN_PROJET,
	AFN_QUANT,
	AJ7_PROJET,
	AFG_PROJET--,
	--dbo.FRETPC(E2_NUM, E2_PREFIXO, E2_FORNECE, E2_LOJA) AS PEDCOM
FROM SE2010
INNER JOIN SE5010 SE5 WITH (NOLOCK)
															ON SE5.E5_FILIAL = ' ' 
															AND E5_NUMERO  = E2_NUM
															AND E5_PREFIXO = E2_PREFIXO
															AND E5_PARCELA = E2_PARCELA
															AND E5_TIPO    = E2_TIPO
															AND E5_CLIFOR  = E2_FORNECE
															AND E5_LOJA    = E2_LOJA 
															AND E5_RECPAG  = 'P'
															AND E5_TIPODOC NOT IN ('BA','ES','DC','JR','MT')                                           
															AND SE5.E5_SEQ IN  (SELECT MAX(TMPSE5.E5_SEQ) 
																				FROM SE5010 TMPSE5 WITH (NOLOCK) WHERE TMPSE5.E5_FILIAL = '  '
																						AND SE5.E5_NUMERO  = TMPSE5.E5_NUMERO
																						AND SE5.E5_PREFIXO = TMPSE5.E5_PREFIXO
																						AND SE5.E5_PARCELA = TMPSE5.E5_PARCELA
																						AND SE5.E5_TIPO    = TMPSE5.E5_TIPO
																						AND SE5.E5_CLIFOR  = TMPSE5.E5_CLIFOR
																						AND SE5.E5_LOJA    = TMPSE5.E5_LOJA
																						AND TMPSE5.E5_RECPAG = 'P'
																						AND TMPSE5.E5_TIPODOC NOT IN ('BA','ES','DC','JR','MT'/*,'TX'*/)
																						AND TMPSE5.D_E_L_E_T_ = ' ')  
														AND SE5.D_E_L_E_T_ = ' '
LEFT JOIN AFR010 AFR WITH (NOLOCK)
	ON AFR.AFR_FILIAL = '  '
		AND AFR_NUM = E2_NUM
		AND AFR_PREFIX = E2_PREFIXO
		AND AFR_PARCEL = E2_PARCELA
		AND AFR_TIPO = E2_TIPO
		AND AFR_FORNEC = E2_FORNECE
		AND AFR_LOJA = E2_LOJA
		AND AFR_REVISA IN (
			SELECT AF8_REVISA
			FROM AF8010 WITH (NOLOCK)
			WHERE AF8_PROJET = AFR_PROJET
			)
		AND AFR.D_E_L_E_T_ = ' '
LEFT JOIN SF1010 SF1 WITH (NOLOCK)
	ON E2_NUM = F1_DOC
		AND E2_PREFIXO = F1_SERIE
		AND E2_FORNECE = F1_FORNECE
		AND E2_LOJA = F1_LOJA
		AND SF1.D_E_L_E_T_ = ' '
LEFT JOIN SD1010 SD1 WITH (NOLOCK)
	ON E2_NUM = D1_DOC
		AND E2_PREFIXO = D1_SERIE
		AND E2_FORNECE = D1_FORNECE
		AND E2_LOJA = D1_LOJA
		AND SD1.D_E_L_E_T_ = ' '
LEFT JOIN AFN010 AFN WITH (NOLOCK)
	ON AFN.AFN_FILIAL = '  '
		AND AFN_DOC = D1_DOC
		AND AFN_SERIE = D1_SERIE
		AND AFN_FORNEC = D1_FORNECE
		AND AFN_LOJA = D1_LOJA
		AND AFN_ITEM = D1_ITEM
		AND AFN_COD = D1_COD
		AND AFN_REVISA IN (
			SELECT AF8_REVISA
			FROM AF8010 WITH (NOLOCK)
			WHERE AF8_FILIAL = ' '
				AND AF8_PROJET = AFN_PROJET
				AND AF8010.D_E_L_E_T_ = '  '
			)
		AND AFN.D_E_L_E_T_ = ' '
LEFT JOIN SC7010 SC7 WITH (NOLOCK)
	ON SC7.C7_NUM = D1_PEDIDO
		AND SC7.C7_ITEM = D1_ITEMPC
		AND SC7.D_E_L_E_T_ = ' '
LEFT JOIN AJ7010 AJ7 WITH (NOLOCK)
	ON AJ7.AJ7_FILIAL = '  '
		AND AJ7_NUMPC = C7_NUM
		AND AJ7_ITEMPC = C7_ITEM
		AND AJ7_COD = C7_PRODUTO
		AND AJ7_REVISA IN (
			SELECT AF8_REVISA
			FROM AF8010 WITH (NOLOCK)
			WHERE AF8_PROJET = AJ7_PROJET
			)
		AND AJ7.D_E_L_E_T_ = ' '
LEFT JOIN AFG010 AFG WITH (NOLOCK)
	ON AFG.AFG_FILIAL = '  '
		AND AFG_NUMSC = C7_NUMSC
		AND AFG_ITEMSC = C7_ITEMSC
		AND AFG_REVISA IN (
			SELECT AF8_REVISA
			FROM AF8010 WITH (NOLOCK)
			WHERE AF8_PROJET = AFG_PROJET
			)
		AND AFG.D_E_L_E_T_ = ' '
LEFT JOIN SC1010 SC1 WITH (NOLOCK)
	ON C7_NUMSC = C1_NUM
		AND C7_ITEMSC = C1_ITEM
		AND SC1.D_E_L_E_T_ = ' '
WHERE E2_NUM = @TITULO
AND E2_FORNECE = @FORNECEDOR
ORDER BY E2_FORNECE

SELECT *
FROM SE5010
WHERE E5_NUMERO = @TITULO

SELECT *
FROM SE2010 
WHERE E2_NUM = @TITULO
AND E2_FORNECE = @FORNECEDOR
ORDER BY E2_FORNECE


--SELECT * FROM AFR010


--SELECT * FROM SE2010 SE2 WHERE SE2.E2_TIPO = 'TX'
