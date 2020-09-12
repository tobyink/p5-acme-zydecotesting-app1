#
# Hack to add Zydeco-created packages into META.json
#

{
	use Module::Runtime qw( module_notional_filename require_module );
	
	my @ZydecoApps = qw(
		Acme::ZydecoTesting::App1
	);

	'Dist::Inkt::Profile::TOBYINK'->meta->add_after_method_modifier(
		'PopulateMetadata',
		sub {
			my $self = shift;
			push @INC, $self->sourcefile('lib')->canonpath;
			print join("|", @INC), "\n\n";
			for my $app ( @ZydecoApps ) {
				require_module($app);
				my $pkgs = do { no strict 'refs'; \%{"$app\::PACKAGES"} };
				for my $pkg ( sort keys %$pkgs ) {
					$self->metadata->{'provides'}{$pkg} ||= {
						'version'  => $pkg->VERSION,
						'file'     => module_notional_filename($app),
					};
					$self->metadata->{'provides'}{$pkg}{'x_type'} = $pkgs->{$pkg},
				}
			}
		},
	);
}