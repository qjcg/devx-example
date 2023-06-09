// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/external-secrets/external-secrets/apis/externalsecrets/v1beta1

package v1beta1

import smmeta "github.com/external-secrets/external-secrets/apis/meta/v1"

// KeeperSecurityProvider Configures a store to sync secrets using Keeper Security.
#KeeperSecurityProvider: {
	authRef:  smmeta.#SecretKeySelector @go(Auth)
	folderID: string                    @go(FolderID)
}
