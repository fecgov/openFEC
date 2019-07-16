/*
define function to convert varchar to form suitable for to_tsvector input while 
by stripping out special characters and preserving the ability to search on accented 
strings as well as unaccented versions of the string. 
*/

CREATE OR REPLACE FUNCTION public.parse_fulltext(t text)
  RETURNS varchar AS
$BODY$

begin

    return 
    case 

        when t = unaccent(t) then regexp_replace(t, '[^a-zA-Z0-9]', ' ', 'g')

        else concat(regexp_replace(unaccent(t), '[^a-zA-Z0-9]', ' ', 'g'), ' ', regexp_replace(t, '[^[:alnum:]]', ' ', 'g'))
    end;

end

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.parse_fulltext(text)
  OWNER TO fec;
GRANT EXECUTE ON FUNCTION public.candidate_election_duration(text) TO public;
GRANT EXECUTE ON FUNCTION public.candidate_election_duration(text) TO fec;
