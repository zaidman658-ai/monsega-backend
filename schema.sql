CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  wachtwoord_hash TEXT NOT NULL,
  naam TEXT NOT NULL,
  leeftijd INTEGER NOT NULL CHECK (leeftijd >= 18),
  locatie_lat DOUBLE PRECISION,
  locatie_lng DOUBLE PRECISION,
  aangemaakt_op TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS profielen (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  foto_urls TEXT[] DEFAULT '{}',
  bio TEXT,
  prompt_vraag TEXT,
  prompt_antwoord TEXT,
  interesse_tags TEXT[] DEFAULT '{}',
  connectie_tags TEXT[] DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a_id UUID REFERENCES users(id),
  user_b_id UUID REFERENCES users(id),
  status TEXT NOT NULL DEFAULT 'voorgesteld' CHECK (status IN ('voorgesteld','geaccepteerd','afgewezen')),
  aangemaakt_op TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS dates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id),
  voorgestelde_tijden_a TIMESTAMPTZ[] DEFAULT '{}',
  voorgestelde_tijden_b TIMESTAMPTZ[] DEFAULT '{}',
  bevestigde_tijd TIMESTAMPTZ,
  locatie TEXT,
  status TEXT NOT NULL DEFAULT 'tijden_kiezen' CHECK (status IN ('tijden_kiezen','bevestigd','voltooid','no_show'))
);

CREATE TABLE IF NOT EXISTS betalingen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date_id UUID REFERENCES dates(id),
  user_id UUID REFERENCES users(id),
  mollie_payment_id TEXT,
  bedrag NUMERIC(6,2) NOT NULL DEFAULT 10.00,
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','betaald','terugbetaald')),
  aangemaakt_op TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS checkins (
  date_id UUID REFERENCES dates(id),
  user_id UUID REFERENCES users(id),
  kwam_opdagen BOOLEAN NOT NULL,
  gemeld_op TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (date_id, user_id)
);

CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date_id UUID REFERENCES dates(id),
  reden TEXT NOT NULL CHECK (reden IN ('tegenstrijdige_meldingen','herhaalde_no_show')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','afgehandeld')),
  actie TEXT,
  aangemaakt_op TIMESTAMPTZ DEFAULT now()
);
